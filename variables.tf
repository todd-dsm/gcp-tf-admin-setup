/*
  -----------------------------------------------------------------------------
                             Initialize/Declare Variables
  -----------------------------------------------------------------------------
*/
variable "region" {
  description = "Deployment Region; from ENV; E.G.: us-west2"
  type        = "string"
}

variable "zone" {
  description = "Deployment Zone(s); from ENV; E.G.: us-west2-a"
  type        = "string"
}

variable "billing_account" {
  description = "billing account id; from ENV; E.G.: 91FA7C-F1BE38-A942A9"
  type        = "string"
}

variable "org_id" {
  description = "Unique Identifier; from ENV; E.G.: 235711131719. REF: https://goo.gl/khphmA"
  type        = "string"
}

variable "project_name" {
  description = "test project; from setup/create-tf-admin.sh"
  type        = "string"
}
