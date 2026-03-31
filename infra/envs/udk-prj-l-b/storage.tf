# ---------------------------------------------------------------------------------------------------------------------
# GCS Buckets
# ---------------------------------------------------------------------------------------------------------------------

# Storage bucket for Cloud Functions source code.
# Configured with standard public access prevention and uniform bucket level access.
module "cloud_functions_bucket" {
  source = "../../modules/cloud-fabric/gcs"

  project_id = var.cloud_functions_bucket_project_id
  name       = var.cloud_functions_bucket_name
  location   = var.cloud_functions_bucket_region

  # HARDCODED POLICY: Mandated by security/org standards for this project type
  uniform_bucket_level_access = true
  public_access_prevention    = "inherited"
  force_destroy               = true

  # Configurable options via variables
  versioning    = var.cloud_functions_bucket_versioning
  storage_class = var.cloud_functions_bucket_storage_class
  iam           = var.cloud_functions_bucket_iam

  # Rule 4: Mandatory labels
  labels = {
    env  = var.cloud_functions_bucket_env
    team = var.cloud_functions_bucket_team
  }
}
