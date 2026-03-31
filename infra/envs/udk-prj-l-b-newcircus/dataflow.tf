# Upload Dataflow Flex Template JSON
resource "google_storage_bucket_object" "dataflow_template" {
  name   = "templates/network-events-template-${filemd5("${path.module}/src/df-src/template.json")}.json"
  bucket = var.network_events_to_bq_template_bucket
  source = "${path.module}/src/df-src/template.json"

  depends_on = [module.dataflow_templates_bucket]
}

# Dataflow job reading from Kafka and streaming to BigQuery
module "network_events_to_bq" {
  source = "../../modules/custom/dataflow"

  project_id = var.network_events_to_bq_project_id
  region     = var.network_events_to_bq_region

  gcs_template_path = "gs://${google_storage_bucket_object.dataflow_template.bucket}/${google_storage_bucket_object.dataflow_template.name}"
  subnetwork        = var.network_events_to_bq_subnetwork

  labels = {
    env  = var.network_events_to_bq_env
    team = var.network_events_to_bq_team
  }
}
