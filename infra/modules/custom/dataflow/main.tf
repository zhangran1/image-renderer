
resource "google_dataflow_flex_template_job" "big_data_job" {
  provider                     = google-beta
  name                         = "dataflow-flextemplates-job"
  project                      = var.project_id
  region                       = var.region
  container_spec_gcs_path      = var.gcs_template_path
  subnetwork                   = var.subnetwork
  skip_wait_on_job_termination = true
  labels                       = var.labels
}