module "gcs" {
  source     = "../../modules/cloud-fabric/gcs"
  project_id = var.project_id
  name       = "prod-bucket-${var.project_id}"
  versioning = true
}

