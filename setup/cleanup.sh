#!/usr/bin/env bash
# shellcheck disable=SC2154
# -----------------------------------------------------------------------------
# PURPOSE:  From the same shell used to create the project, call this script.
# -----------------------------------------------------------------------------
#    EXEC:  ./cleanup.sh
# -----------------------------------------------------------------------------
set -x

# Remove bucket contents, then the bucket
gsutil rm -r "gs://${TF_VAR_bucket_name}"
# then remove the bucket
gsutil rb -f "gs://${TF_VAR_bucket_name}"

# delete the project
gcloud projects delete -q "$TF_ADMIN"

# go back to default project
defaultProject="$(gcloud projects list --format 'value(PROJECT_ID)')"
gcloud config set project "$defaultProject"

# show the result
gcloud config configurations list
