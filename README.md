# gcp-tf-admin-setup

This is based on a great piece, [Managing GCP Projects with Terraform], by the community. Unfortunately, it's old an not all the steps work as expected.

As a result, had a hell of a time with setting up _Terraform Admin Project_; thought I would save others the first few steps.

## Before you begin
There are 2 types of accounts in the GCP world:
* Individual
* Organization 

This walk-through assumes you already have a GCP account set up for an _Organization_ and that you are allowed to make **organizational-level** changes in the account.

It assumes a POSIX-like workstation; either macOS or Linux.

It assumes the first (admin) user is configured, authenticated and authorized to perform the first few steps.


# Installs
[Homebrew] after all, we're not savages.

`brew cask install --force google-cloud-sdk`

`brew install terraform`

[gsutil] for managing Google Storage from the CLI

The configurations are coming soon to the wiki; not there yet.


## Do the Work

`git clone git@github.com:todd-dsm/gcp-tf-admin-setup.git && cd gcp-tf-admin-setup/`

**Source-in your env vars by passing an argument to the script.** 

`source setup/env-vars.sh stage`

This file is configured with TF_ADMIN="tester-01-yo". Leave this be until you have the permissions worked out for your first (admin) user. Until those details are worked out the first few runs will be throw-away. And it's easy to increment.

 
**Run the script**

`setup/create-tf-admin.sh 2>&1 | tee /tmp/create-tf-admin.out`

`set -x` is turned on; you'll be able to see all the gory details on-screen and in the log.

Now your admin user `user@domain.tld` account is associated with a service account and you can run Terraform with it.

`cat ~/.config/gcloud/tester-01-yo.json` to see the service account details.

There seems to be a bug in `gcloud` and it will not recognize the `GOOGLE_APPLICATION_CREDENTIALS` value from the export at the end of the script. Just drop it in your `~/.bashrc` file like:

```
grep GOOGLE ~/.bashrc 
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/tester-01-yo.json"
```

and source it in: `source ~/.bashrc`. for some reason that works great.


_NOTE: failed runs can be cleaned up easily by running:_

`setup/cleanup.sh`

_NOTE: after subsequent runs the account number can be incremented by running:_

`sed -i '/GOOGLE_APPLICATION_CREDENTIALS/ s/00/01/' ~/.bashrc`


## Terraform

For reasons you'll come to find on your own, the Terraform bits have been abstracted away to a `Makefile`. To run it:

**Initialize**

```
$ make tf-init 
terraform init -get=true

Initializing the backend...

Successfully configured the backend "gcs"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "google" (1.19.1)...
- Downloading plugin for provider "random" (2.0.0)...
...
* provider.google: version = "~> 1.19"
* provider.random: version = "~> 2.0"
...
Terraform has been successfully initialized!
```

**Plan**

```
$ make plan
...
terraform plan -no-color \
	-out=/tmp/kubes-stage-la.plan 2>&1 | tee /tmp/tf-stage-la-plan.out
Acquiring state lock. This may take a few moments...
Refreshing Terraform state in-memory prior to plan...
...
------------------------------------------------------------------------

This plan was saved to: /tmp/kubes-stage-la.plan

To perform exactly these actions, run the following command to apply:
    terraform apply "/tmp/kubes-stage-la.plan"
```

**Apply**

```
$ make apply
...
terraform apply --auto-approve -no-color \                                 
    -input=false /tmp/kubes-stage-la.plan 2>&1 | tee /tmp/tf-stage-la-plan.out
```

This will apply the plan, create a log of the proceedings and store state in the bucket; it takes about 1 minute and 30 seconds. To see the backup:

```
$ gsutil ls -r gs://tester-01-yo
gs://tester-01-yo/terraform/:

gs://tester-01-yo/terraform/state/:
gs://tester-01-yo/terraform/state/default.tfstate  <-- your state!
```

**Destroy** the Terraformed configuration

This will destroy remote resources from GCP, sync the state again and remove local stuff.

``` 
terraform destroy --force -auto-approve 2>&1 | \
	tee /tmp/tf-stage-la-destroy.out

Destroy complete!
rm -f "/tmp/kubes-stage-la.plan"
rm -rf .terraform
```

## Afterwards

You're left with a service account that you can use to Terraform projects in a safe space. That service account is empowered to do most everything it needs to. 

Effectively, you're ready to start terraforming.


[gsutil]:https://cloud.google.com/storage/docs/gsutil_install

[Homebrew]:https://brew.sh/
[Managing GCP Projects with Terraform]:https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform
[Google Cloud]: https://cloud.google.com/free/