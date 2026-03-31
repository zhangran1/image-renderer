# Service account for Anomaly Detection Function
module "anomaly_detection_func_sa" {
  source = "../../modules/cloud-fabric/iam-service-account"
  project_id = var.anomaly_detection_func_sa_project_id
  name       = var.anomaly_detection_func_sa_name

  iam_project_roles = {
    "${var.anomaly_detection_func_sa_target_project_id}" = [
      "roles/bigquery.dataViewer",
      "roles/bigquery.jobUser",
      "roles/redis.editor"
    ]
  }
}

# Zip local source code
data "archive_file" "anomaly_func_zip" {
  type        = "zip"
  output_path = "${path.module}/.terraform/tmp/anomaly-func-source.zip"
  source_dir  = "${path.module}/../../../src/anomaly-detection-workflow/cloud_function"
}

# Upload zipped source code to GCS
resource "google_storage_bucket_object" "anomaly_func_zip" {
  name   = "anomaly-func-${data.archive_file.anomaly_func_zip.output_md5}.zip"
  bucket = var.cloud_functions_bucket_name
  source = data.archive_file.anomaly_func_zip.output_path

  depends_on = [module.cloud_functions_bucket]
}

# Cloud Function: Anomaly Detection
module "anomaly_detection_func" {
  source = "../../modules/cloud-fabric/cloud-function-v2"

  project_id  = var.anomaly_detection_func_project_id
  region      = var.anomaly_detection_func_region
  name        = var.anomaly_detection_func_name
  bucket_name = google_storage_bucket_object.anomaly_func_zip.bucket

  # Source code in GCS format (uploaded dynamically)
  bundle_config = {
    path = "gs://${google_storage_bucket_object.anomaly_func_zip.bucket}/${google_storage_bucket_object.anomaly_func_zip.name}"
  }

  function_config = {
    runtime            = var.anomaly_detection_func_runtime
    cpu                = var.anomaly_detection_func_cpu
    instance_count     = var.anomaly_detection_func_max_instances
    min_instance_count = var.anomaly_detection_func_min_instances
    memory_mb          = var.anomaly_detection_func_memory_mb
    timeout_seconds    = var.anomaly_detection_func_timeout_seconds
    entry_point        = var.anomaly_detection_func_entry_point
  }

  direct_vpc_egress = {
    mode       = "VPC_EGRESS_PRIVATE_RANGES_ONLY"
    network    = var.anomaly_detection_func_vpc_network
    subnetwork = var.anomaly_detection_func_vpc_subnetwork
  }

  iam = {
    # The function must not allow unauthenticated access and should only allow authenticated IAM access 
    "roles/run.invoker"            = ["serviceAccount:${module.anomaly_detection_func_sa.email}"]
    "roles/cloudfunctions.invoker" = ["serviceAccount:${module.anomaly_detection_func_sa.email}"]
  }

  service_account_config = {
    email  = module.anomaly_detection_func_sa.email
    create = false
  }

  labels = {
    env  = var.anomaly_detection_func_env
    team = var.anomaly_detection_func_team
  }

  depends_on = [
    module.anomaly_detection_func_sa
  ]
}
