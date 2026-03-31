# ---------------------------------------------------------------------------------------------------------------------
# GCS Buckets
# ---------------------------------------------------------------------------------------------------------------------

# Storage bucket for Dataflow Flex Templates
module "dataflow_templates_bucket" {
  source = "../../modules/cloud-fabric/gcs"

  project_id = var.network_events_to_bq_project_id
  name       = var.network_events_to_bq_template_bucket
  location   = var.network_events_to_bq_region

  uniform_bucket_level_access = true
  public_access_prevention    = "inherited"
  force_destroy               = true
  storage_class               = var.network_events_to_bq_template_bucket_storage_class


  labels = {
    env  = var.network_events_to_bq_env
    team = var.network_events_to_bq_team
  }
}
