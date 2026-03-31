# Dataset for storing application analytics events and core data.
# Created to support the data warehousing requirements for the Dev environment.
module "app_bigquery_dataset" {
  source   = "../../modules/cloud-fabric/bigquery"
  for_each = var.bigquery_datasets

  project_id = var.app_bigquery_dataset_project_id
  id         = each.value.id
  location   = each.value.location

  # IAM bindings via variable map
  iam = each.value.iam

  labels = {
    env  = each.value.env
    team = each.value.team
  }
}
