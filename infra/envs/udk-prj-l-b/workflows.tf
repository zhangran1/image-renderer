# Service account for the APIC Change Detection Workflow
module "anomaly_detection_workflow_sa" {
  source = "../../modules/cloud-fabric/iam-service-account"
  project_id = var.anomaly_detection_workflow_sa_project_id
  name       = var.anomaly_detection_workflow_sa_name

  iam_project_roles = {
    "${var.anomaly_detection_workflow_sa_target_project_id}" = [
      "roles/run.invoker",
      "roles/cloudfunctions.invoker",
      "roles/logging.logWriter"
    ]
  }
}


# Service Account for the Scheduler Trigger
module "anomaly_detection_scheduler_sa" {
  source = "../../modules/cloud-fabric/iam-service-account"
  project_id = var.anomaly_detection_scheduler_sa_project_id
  name       = var.anomaly_detection_scheduler_sa_name

  iam_project_roles = {
    "${var.anomaly_detection_scheduler_sa_target_project_id}" = [
      "roles/run.invoker",
      "roles/cloudfunctions.invoker",
      "roles/workflows.invoker" 
    ]
  }
}

# Cloud Workflow invoking the APIC Change Detection function
module "anomaly_detection_workflow" {
  source = "../../modules/custom/workflows"

  project_id      = var.anomaly_detection_workflow_project_id
  region          = var.anomaly_detection_workflow_region
  name            = var.anomaly_detection_workflow_name
  description     = var.anomaly_detection_workflow_description
  service_account = module.anomaly_detection_workflow_sa.email
  source_contents = file("${path.module}/../../../src/anomaly-detection-workflow/workflow/workflow.yaml")

  # Standard resource labels
  labels = {
    env  = var.anomaly_detection_workflow_env
    team = var.anomaly_detection_workflow_team
  }

  # Scheduler Trigger (Every 10 mins)
  workflow_trigger = {
    cloud_scheduler = {
      name                  = var.anomaly_detection_workflow_trigger_name
      cron                  = var.anomaly_detection_workflow_trigger_cron
      time_zone             = var.anomaly_detection_workflow_trigger_time_zone
      deadline              = var.anomaly_detection_workflow_trigger_deadline
      service_account_email = module.anomaly_detection_scheduler_sa.email
      argument = jsonencode({
        project_id         = var.anomaly_detection_workflow_project_id
        bq_dataset         = var.anomaly_detection_workflow_bq_dataset
        bq_table           = var.anomaly_detection_workflow_bq_table
        bq_model_name      = var.anomaly_detection_workflow_bq_model_name
        time_column        = var.anomaly_detection_workflow_time_column
        value_column       = var.anomaly_detection_workflow_value_column
        cloud_function_url = module.anomaly_detection_func.uri
        redis_host         = data.terraform_remote_state.newcircus.outputs.redis_host
        redis_port         = data.terraform_remote_state.newcircus.outputs.redis_port
      })
    }
  }

  depends_on = [
    module.anomaly_detection_workflow_sa,
    module.anomaly_detection_scheduler_sa
  ]
}
