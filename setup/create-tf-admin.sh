#!/usr/bin/env bash
# shellcheck disable=SC2154
# -----------------------------------------------------------------------------
# PURPOSE:  1-time setup for the admin-project and terraform user account.
#           Some controls are necessary at the Organization and project level.
# -----------------------------------------------------------------------------
#    EXEC:  setup/create-tf-admin.sh project
# -----------------------------------------------------------------------------
set -x

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
declare -r svcAcctName='terraform'
serviceEmail="${svcAcctName}@${TF_ADMIN}.iam.gserviceaccount.com"
# TARGET FORMAT:   terraform@tf-admin-$USER.iam.gserviceaccount.com
serviceAccount="serviceAccount:${serviceEmail}"
declare -a envVARs=('TF_ADMIN' 'TF_CREDS' 'TF_VAR_org_id')
declare -a gcpRoles=('viewer' 'storage.admin')
declare -a projAPIs=('cloudresourcemanager' 'cloudbilling' 'iam' 'compute')
declare -a orgPerms=('resourcemanager.projectCreator' 'billing.user')


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
function pMsg() {
    theMessage="$1"
    printf '%s\n' "$theMessage"
}

###----------------------------------------------------------------------------
### MAIN
###----------------------------------------------------------------------------
### Check some basic assumptions
###---
printf '\n\n%s\n' "Verifying all ENV variables are available..."
for reqdVar in "${envVARs[@]}"; do
    if [[ -z "${!reqdVar}" ]]; then
        pMsg "$reqdVar is not set; exiting."
        exit 1
    else
        pMsg "  * $reqdVar = ${!reqdVar}"
    fi
done

# Success
pMsg "All required variables check-out; advancing to the next step."


###---
### Create the Terraform Admin Project and
###---
gcloud projects create "$TF_ADMIN" \
    --organization "$TF_VAR_org_id" \
    --set-as-default

### Link the Admin project space to the billing account
gcloud beta billing projects link "$TF_ADMIN" \
    --billing-account "$TF_VAR_billing_account"

### Link the Admin project space to the billing account
gcloud config set project "$TF_ADMIN"


###---
### Create the service account in the Terraform admin project and
### download the JSON credentials
###---
pMsg "Creating 'terraform' service-account..."
gcloud iam service-accounts create "$svcAcctName" \
    --display-name "Terraform admin account for $USER"

pMsg "Creating keys for 'terraform' service-account..."
gcloud iam service-accounts keys create "$TF_CREDS" \
    --iam-account "$serviceEmail"


###---
### Grant the service account permission to:
###   * view the Admin Project, and
###   * manage Cloud Storage
###---
printf '\n\n%s\n' "Granting roles to $TF_ADMIN..."
for adminRole in "${gcpRoles[@]}"; do
    gcloud projects add-iam-policy-binding "$TF_ADMIN" \
        --member "$serviceAccount" \
        --role   "roles/${adminRole}"
    pMsg "  * $adminRole"
done


###---
### Enable the APIs
### Any action taken by Terraform (using the TF_ADMIN serviceAccount) requires
### requisite APIs are enabled. Terraform requires APIs in the projAPIs array.
###---
printf '\n\n%s\n' "Enabling required APIs for $TF_ADMIN..."
for adminAPI in "${projAPIs[@]}"; do
    gcloud services enable "${adminAPI}.googleapis.com"
    pMsg "  * $adminAPI"
done


###---
### Add organization/folder-level permissions
### Grant the serviceAccount permission to:
###   * create projects, and
###   * assign billing accounts
###---
printf '\n\n%s\n' "Adding organization/folder-level permissions for $TF_ADMIN..."
for adminPerms in "${orgPerms[@]}"; do
    gcloud organizations add-iam-policy-binding "$TF_VAR_org_id" \
        --member "$serviceAccount" \
        --role "roles/${adminPerms}"
    pMsg "  * $adminPerms"
done


###---
### Setup Terraform state storage
###---
printf '\n\n%s\n' "Creating a bucket for remote terraform state..."
gsutil mb -p "$TF_ADMIN" "gs://${TF_ADMIN}"

cat > backend.tf <<EOF
/*
  -----------------------------------------------------------------------------
                           CENTRALIZED HOME FOR STATE
                           inerpolations NOT allowed
  -----------------------------------------------------------------------------
*/
terraform {
  backend "gcs" {
    bucket  = "$TF_ADMIN"
    project = "$TF_ADMIN"
    prefix  = "terraform/state"
  }
}
EOF


###---
### Enable storage versioning
###---
gsutil versioning set on "gs://${TF_ADMIN}"


###---
### Export the goodies
###---
export GOOGLE_APPLICATION_CREDENTIALS="$TF_CREDS"
export GOOGLE_PROJECT="$TF_ADMIN"
export TF_VAR_project_name="$TF_ADMIN"


###---
### fin~
###---
exit 0

