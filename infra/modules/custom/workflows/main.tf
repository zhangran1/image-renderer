
resource "google_workflows_workflow" "my_workflow" {
  project             = var.project_id
  name                = var.name
  region              = var.region
  description         = var.description
  service_account     = var.service_account
  deletion_protection = var.deletion_protection
  labels              = var.labels
  tags                = var.tags
  source_contents     = var.source_contents

}

resource "google_cloud_scheduler_job" "workflow_trigger" {
  for_each = var.workflow_trigger.cloud_scheduler != null ? { 1 = 1 } : {}

  project     = var.project_id
  region      = var.region
  name        = var.workflow_trigger.cloud_scheduler.name
  description = "Trigger for workflow: ${var.name}"
  schedule    = var.workflow_trigger.cloud_scheduler.cron
  time_zone   = var.workflow_trigger.cloud_scheduler.time_zone

  attempt_deadline = var.workflow_trigger.cloud_scheduler.deadline

  retry_config {
    retry_count = 1 
  }

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/${google_workflows_workflow.my_workflow.id}/executions"
    
    oauth_token {
      service_account_email = coalesce(
        var.workflow_trigger.cloud_scheduler.service_account_email,
        var.service_account
      )
    }
  }
}