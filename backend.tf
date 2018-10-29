/*
  -----------------------------------------------------------------------------
                           CENTRALIZED HOME FOR STATE
                           inerpolations NOT allowed
  -----------------------------------------------------------------------------
*/
terraform {
  backend "gcs" {
    bucket  = "tester-01-yo"
    project = "tester-01-yo"
    prefix  = "terraform/state"
  }
}
