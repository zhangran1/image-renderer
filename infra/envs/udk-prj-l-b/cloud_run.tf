
# ---------------------------------------------------------------------------------------------------------------------
# Anomaly Detection Service (Cloud Run V2)
# ---------------------------------------------------------------------------------------------------------------------

# Service Account for Cloud Run Service
module "anomaly_detection_service_sa" {
  source = "../../modules/cloud-fabric/iam-service-account"
  project_id = var.anomaly_detection_service_sa_project_id
  name       = var.anomaly_detection_service_sa_name

  iam_project_roles = {
    "${var.anomaly_detection_service_sa_target_project_id}" = [
      "roles/bigquery.dataViewer",
      "roles/bigquery.jobUser",
      "roles/redis.editor",
      "roles/logging.logWriter"
    ]
  }
}

# Cloud Run Service (Unmanaged)
module "anomaly_detection_service" {
  source = "../../modules/cloud-fabric/cloud-run-v2"
  project_id = var.anomaly_detection_service_project_id
  region     = var.anomaly_detection_service_region
  name       = var.anomaly_detection_service_name

  deletion_protection = var.anomaly_detection_service_deletion_protection
  launch_stage        = var.anomaly_detection_service_launch_stage

  # CRITICAL: Allow external deployments to update the image
  managed_revision = false

  service_account_config = {
    create = false
    email  = module.anomaly_detection_service_sa.email
  }

  # Service Config constructed from granular variables
  service_config = {
    ingress = "INGRESS_TRAFFIC_ALL" # Public service
    timeout = var.anomaly_detection_service_timeout
    scaling = {
      min_instance_count = var.anomaly_detection_service_min_instances
      max_instance_count = var.anomaly_detection_service_max_instances
    }
  }

  # VPC Access
  revision = {
    vpc_access = var.anomaly_detection_service_vpc_access
  }


  # Labels
  labels = {
    env  = var.anomaly_detection_service_env
    team = var.anomaly_detection_service_team
  }

  # Container Definition constructed from granular variables
  containers = {
    "app" = {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      resources = {
        limits = {
          cpu    = var.anomaly_detection_service_cpu
          memory = var.anomaly_detection_service_memory
        }
      }
      liveness_probe = var.anomaly_detection_service_liveness_probe
      startup_probe  = var.anomaly_detection_service_startup_probe
    }
  }
}
