#!/usr/bin/env bash
# PURPOSE:  Generate some variables for GCP/GKE. This file is called with one
#           argument while sourcing it in.
# -----------------------------------------------------------------------------
#    EXEC:  source ./setup/env-vars.sh <prod|stage>
# -----------------------------------------------------------------------------
set -x

# -----------------------------------------------------------------------------
# The Build Environment
envBuild="$1"

# -----------------------------------------------------------------------------
# Organization stuff
# gcloud organizations list
export TF_VAR_org_id="$(gcloud organizations list --format='value(ID)')"
# gcloud beta billing accounts list
export TF_VAR_billing_account="$(gcloud beta billing accounts list \
    --format='value(ACCOUNT_ID)')"

# Same for either ENV
export TF_VAR_region="$(gcloud config list --format 'value(compute.region)')"
export TF_VAR_zone="$(gcloud config list --format 'value(compute.zone)')"
export newClusterName="$envBuild-la"


# -----------------------------------------------------------------------------
# Terraform Constants
case "$envBuild" in
    stage)
        export TF_VAR_host_cidr='10.128.0.0/20'
        export TF_VAR_controller_count='1'
        export TF_VAR_controller_type='g1-small'
        export TF_VAR_worker_count='1'
        export TF_VAR_worker_type='g1-small'
        ;;
    prod)
        export TF_VAR_region='us-west2'
        export TF_VAR_host_cidr='10.0.0.0/20'
        export TF_VAR_controller_count='3'
        export TF_VAR_controller_type='n1-standard-1'   # need this?
        export TF_VAR_worker_count='3'
        export TF_VAR_worker_type='n1-standard-1'
        ;;
    *)  echo "$envBuild is unsupported; exiting."
        ;;
esac


# -----------------------------------------------------------------------------
# Same for either ENV; depends on case
export TF_VAR_cluster_name="$newClusterName"
#export TF_ADMIN="tf-admin-${USER}"
export TF_ADMIN="tester-01-yo"
export TF_VAR_bucket_name="${TF_ADMIN}"
export TF_CREDS="$HOME/.config/gcloud/${TF_ADMIN}.json"
export planFile="/tmp/kubes-${newClusterName}.plan"
set +x
