
resource "google_cloud_scheduler_job" "job" {
  project          = var.project_id
  region           = var.region
  name             = var.name
  description      = var.description
  schedule         = var.schedule
  time_zone        = var.time_zone
  attempt_deadline = var.attempt_deadline


  retry_config {
    retry_count = var.retry_count
  }

  http_target {
    http_method = var.http_method
    uri         = var.uri
    body        = var.body != null ? base64encode(var.body) : null
    headers     = var.headers

    oidc_token {
      service_account_email = var.service_account_email
    }
  }
}
