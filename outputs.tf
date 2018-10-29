/*
  -----------------------------------------------------------------------------
                                     OUTPUTS
  -----------------------------------------------------------------------------
*/
output "project_id" {
  value = "${google_project.project.project_id}"
}

output "rando_id" {
  value = "${random_id.id.id}"
}

output "project_name" {
  value = "${google_project.project.name}"
}

output "enabled_apis" {
  value = "${google_project_services.project.services}"
}
