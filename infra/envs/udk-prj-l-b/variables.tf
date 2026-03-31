# ---------------------------------------------------------------------------------------------------------------------
# Provider Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "provider_project_id" {
  description = "Project ID for the provider."
  type        = string
}

variable "provider_region" {
  description = "Region for the provider."
  type        = string
  default     = "us-central1"
}

# ---------------------------------------------------------------------------------------------------------------------
# GCS Variables (Cloud Functions)
# ---------------------------------------------------------------------------------------------------------------------

variable "cloud_functions_bucket_project_id" {
  description = "Project ID for the Cloud Functions source bucket."
  type        = string
}

variable "cloud_functions_bucket_region" {
  description = "Region for the Cloud Functions source bucket."
  type        = string
}

variable "cloud_functions_bucket_env" {
  description = "Environment label for the Cloud Functions source bucket."
  type        = string
}

variable "cloud_functions_bucket_team" {
  description = "Team label for the Cloud Functions source bucket."
  type        = string
}

variable "cloud_functions_bucket_name" {
  description = "The globally unique name for the Cloud Functions source bucket."
  type        = string
}

variable "cloud_functions_bucket_versioning" {
  description = "Boolean flag to enable object versioning."
  type        = bool
  default     = true
}

variable "cloud_functions_bucket_iam" {
  description = "IAM bindings for the Cloud Functions source bucket."
  type        = map(list(string))
  default     = {}
}

variable "cloud_functions_bucket_storage_class" {
  description = "The storage class of the Cloud Functions bucket."
  type        = string
  default     = "STANDARD"
}

# ---------------------------------------------------------------------------------------------------------------------
# Anomaly Detection Function
# ---------------------------------------------------------------------------------------------------------------------

variable "anomaly_detection_func_project_id" {
  description = "Project ID for the anomaly detection function."
  type        = string
}

variable "anomaly_detection_func_region" {
  description = "Region for the anomaly detection function."
  type        = string
}

variable "anomaly_detection_func_env" {
  description = "Environment label for the anomaly detection function."
  type        = string
}

variable "anomaly_detection_func_team" {
  description = "Team label for the anomaly detection function."
  type        = string
}

variable "anomaly_detection_func_name" {
  description = "Name for the anomaly detection function."
  type        = string
}

variable "anomaly_detection_func_bucket_name" {
  description = "Name of the bucket used for the cloud function."
  type        = string
}

variable "anomaly_detection_func_entry_point" {
  description = "Entry point in the code for the anomaly detection function."
  type        = string
}

variable "anomaly_detection_func_min_instances" {
  description = "Minimum number of instances for the anomaly detection function."
  type        = number
  default     = 0
}

variable "anomaly_detection_func_max_instances" {
  description = "Maximum number of instances for the anomaly detection function."
  type        = number
  default     = 10
}

variable "anomaly_detection_func_timeout_seconds" {
  description = "Timeout in seconds for the anomaly detection function."
  type        = number
  default     = 180
}

variable "anomaly_detection_func_memory_mb" {
  description = "Memory limit in MB for the anomaly detection function."
  type        = number
  default     = 256
}

variable "anomaly_detection_func_cpu" {
  description = "CPU limit for the anomaly detection function."
  type        = string
  default     = "1"
}

variable "anomaly_detection_func_runtime" {
  description = "Runtime for the anomaly detection function."
  type        = string
  default     = "python310"
}

variable "anomaly_detection_func_vpc_network" {
  description = "VPC network for Direct VPC Egress."
  type        = string
}

variable "anomaly_detection_func_vpc_subnetwork" {
  description = "VPC subnetwork for Direct VPC Egress."
  type        = string
}

variable "anomaly_detection_func_sa_project_id" {
  description = "Project ID for the anomaly detection function Service Account."
  type        = string
}

variable "anomaly_detection_func_sa_target_project_id" {
  description = "Project ID where the anomaly detection function Service Account will be granted IAM roles."
  type        = string
}

variable "anomaly_detection_func_sa_name" {
  description = "Name for the anomaly detection function Service Account."
  type        = string
}


# ---------------------------------------------------------------------------------------------------------------------
# Daily APIC Scheduler Job
# ---------------------------------------------------------------------------------------------------------------------

variable "daily_apic_job_project_id" {
  description = "Project ID for the Daily APIC Scheduler job."
  type        = string
}

variable "daily_apic_job_region" {
  description = "Region for the Daily APIC Scheduler job."
  type        = string
}

variable "daily_apic_job_name" {
  description = "Name of the Daily APIC Scheduler job."
  type        = string
}

variable "daily_apic_job_schedule" {
  description = "Cron schedule for the Daily APIC Scheduler job."
  type        = string
}

variable "daily_apic_job_sa_project_id" {
  description = "Project ID for the Daily APIC Scheduler job Service Account."
  type        = string
}

variable "daily_apic_job_sa_name" {
  description = "Name of the Daily APIC Scheduler job Service Account."
  type        = string
}

variable "daily_apic_job_env" {
  description = "Environment label for the daily APIC job."
  type        = string
}

variable "daily_apic_job_team" {
  description = "Team label for the daily APIC job."
  type        = string
}

variable "daily_apic_job_sa_target_project_id" {
  description = "Project ID where the Daily APIC Scheduler job SA will be granted IAM roles."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# Workflow Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "anomaly_detection_workflow_sa_project_id" {
  description = "Project ID where the Network Anomaly Detection Workflow SA will be created."
  type        = string
}

variable "anomaly_detection_workflow_sa_name" {
  description = "Name for the Network Anomaly Detection Workflow Service Account."
  type        = string
}

variable "anomaly_detection_workflow_project_id" {
  description = "Project ID where the Network Anomaly Detection Workflow will be deployed."
  type        = string
}

variable "anomaly_detection_workflow_region" {
  description = "Region where the Network Anomaly Detection Workflow will be deployed."
  type        = string
}

variable "anomaly_detection_workflow_name" {
  description = "Name of the Network Anomaly Detection Workflow."
  type        = string
}

variable "anomaly_detection_workflow_description" {
  description = "Description of the Network Anomaly Detection Workflow."
  type        = string
}

variable "anomaly_detection_workflow_env" {
  description = "Environment label for the Workflow (e.g., dev, prod)."
  type        = string
}

variable "anomaly_detection_workflow_team" {
  description = "Team label responsible for the Workflow."
  type        = string
}

variable "anomaly_detection_workflow_sa_target_project_id" {
  description = "Project ID where the Anomaly Detection Workflow SA will be granted IAM roles."
  type        = string
}

variable "anomaly_detection_workflow_bq_dataset" {
  description = "BigQuery dataset name for the network anomaly detection workflow."
  type        = string
}

variable "anomaly_detection_workflow_bq_table" {
  description = "BigQuery table name for the network anomaly detection workflow."
  type        = string
}

variable "anomaly_detection_workflow_bq_model_name" {
  description = "BigQuery model name for the network anomaly detection workflow."
  type        = string
}

variable "anomaly_detection_workflow_time_column" {
  description = "Time column for the network anomaly detection workflow."
  type        = string
  default     = "timestamp"
}

variable "anomaly_detection_workflow_value_column" {
  description = "Value column for the network anomaly detection workflow."
  type        = string
  default     = "value"
}

variable "anomaly_detection_workflow_redis_host" {
  description = "Redis host for the network anomaly detection workflow."
  type        = string
}

variable "anomaly_detection_workflow_redis_port" {
  description = "Redis port for the network anomaly detection workflow."
  type        = number
  default     = 6379
}


variable "anomaly_detection_workflow_trigger_name" {
  description = "Name of the Cloud Scheduler trigger for the workflow."
  type        = string
  default     = "anomaly_detect_scheduler"
}

variable "anomaly_detection_workflow_trigger_cron" {
  description = "Cron schedule for the workflow trigger."
  type        = string
  default     = "*/10 * * * *"
}

variable "anomaly_detection_workflow_trigger_time_zone" {
  description = "Time zone for the workflow trigger."
  type        = string
  default     = "America/New_York"
}

variable "anomaly_detection_workflow_trigger_deadline" {
  description = "Deadline for the workflow trigger."
  type        = string
  default     = "7200s"
}

variable "anomaly_detection_scheduler_sa_name" {
  description = "Name for the Anomaly Detect Scheduler Service Account."
  type        = string
}

variable "anomaly_detection_scheduler_sa_project_id" {
  description = "Project ID where the Scheduler Service Account will be created."
  type        = string
}

variable "anomaly_detection_scheduler_sa_target_project_id" {
  description = "Project ID where the Scheduler Service Account will be granted IAM roles."
  type        = string
}


# ---------------------------------------------------------------------------------------------------------------------
# Anomaly Detection Service (Cloud Run V2)
# ---------------------------------------------------------------------------------------------------------------------

variable "anomaly_detection_service_name" {
  description = "Name of the Anomaly Detection Cloud Run service."
  type        = string
}

variable "anomaly_detection_service_project_id" {
  description = "Project ID where the service will be deployed."
  type        = string
}

variable "anomaly_detection_service_region" {
  description = "Region where the service will be deployed."
  type        = string
}



variable "anomaly_detection_service_vpc_access" {
  description = "VPC access configuration for the service."
  type = object({
    connector = optional(string)
    egress    = optional(string)
    network   = optional(string)
    subnet    = optional(string)
    tags      = optional(list(string))
  })
  default = {}
}

variable "anomaly_detection_service_sa_name" {
  description = "Name for the Anomaly Detection Service Account."
  type        = string
}

variable "anomaly_detection_service_sa_project_id" {
  description = "Project ID where the Anomaly Detection Service Account will be created."
  type        = string
}

variable "anomaly_detection_service_sa_target_project_id" {
  description = "Project ID where the Anomaly Detection Service Account will be granted IAM roles."
  type        = string
}

variable "anomaly_detection_service_deletion_protection" {
  description = "Whether to enable deletion protection for the service."
  type        = bool
  default     = false
}

variable "anomaly_detection_service_launch_stage" {
  description = "The launch stage of the service (e.g., GA, BETA)."
  type        = string
  default     = "GA"
}


variable "anomaly_detection_service_min_instances" {
  description = "Minimum number of instances for the service."
  type        = number
  default     = 0
}

variable "anomaly_detection_service_max_instances" {
  description = "Maximum number of instances for the service."
  type        = number
  default     = 10
}

variable "anomaly_detection_service_timeout" {
  description = "Request timeout duration (e.g., '60s')."
  type        = string
  default     = "60s"
}

variable "anomaly_detection_service_cpu" {
  description = "CPU limit for the container (e.g., '1000m')."
  type        = string
  default     = "1000m"
}

variable "anomaly_detection_service_memory" {
  description = "Memory limit for the container (e.g., '512Mi')."
  type        = string
  default     = "512Mi"
}

variable "anomaly_detection_service_invoker_members" {
  description = "List of IAM members allowed to invoke the service."
  type        = list(string)
  default     = []
}


variable "anomaly_detection_service_env" {
  description = "Environment label for the Anomaly Detection service."
  type        = string
}

variable "anomaly_detection_service_team" {
  description = "Team label for the Anomaly Detection service."
  type        = string
}

variable "anomaly_detection_service_image" {
  description = "Docker image for the Anomaly Detection service."
  type        = string
}

variable "anomaly_detection_service_liveness_probe" {
  description = "Liveness probe configuration for the service."
  type = object({
    grpc = optional(object({
      port    = optional(number)
      service = optional(string)
    }))
    http_get = optional(object({
      http_headers = optional(map(string))
      path         = optional(string)
      port         = optional(number)
    }))
    failure_threshold     = optional(number)
    initial_delay_seconds = optional(number)
    period_seconds        = optional(number)
    timeout_seconds       = optional(number)
    tcp_socket = optional(object({
      port = optional(number)
    }))
  })
  default = null
}

variable "anomaly_detection_service_startup_probe" {
  description = "Startup probe configuration for the service."
  type = object({
    grpc = optional(object({
      port    = optional(number)
      service = optional(string)
    }))
    http_get = optional(object({
      http_headers = optional(map(string))
      path         = optional(string)
      port         = optional(number)
    }))
    failure_threshold     = optional(number)
    initial_delay_seconds = optional(number)
    period_seconds        = optional(number)
    timeout_seconds       = optional(number)
    tcp_socket = optional(object({
      port = optional(number)
    }))
  })
  default = null
}

# ---------------------------------------------------------------------------------------------------------------------
# Git Runner Configuration
# ---------------------------------------------------------------------------------------------------------------------

variable "git_runner_machine_type" {
  description = "Machine type for the Git Runner instances."
  type        = string
  default     = "e2-standard-4"
}

variable "git_runner_image" {
  description = "Source image for the Git Runner instances."
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "git_runner_min_replicas" {
  description = "Minimum number of Git Runner replicas."
  type        = number
  default     = 1
}

variable "git_runner_max_replicas" {
  description = "Maximum number of Git Runner replicas."
  type        = number
  default     = 5
}

variable "git_runner_disk_size_gb" {
  description = "Boot disk size in GB for Git Runner."
  type        = number
  default     = 50
}

variable "git_runner_service_account_name" {
  description = "Name of the service account for Git Runner."
  type        = string
  default     = "git-runner-sa"
}

variable "git_runner_vpc_network" {
  description = "VPC network for Git Runner."
  type        = string
}

variable "git_runner_vpc_subnetwork" {
  description = "VPC subnetwork for Git Runner."
  type        = string
}

variable "git_runner_project_id" {
  description = "Project ID for Git Runner resources."
  type        = string
}

variable "git_runner_region" {
  description = "Region for Git Runner resources."
  type        = string
}

variable "git_runner_env" {
  description = "Environment label for Git Runner."
  type        = string
}


variable "git_runner_startup_script" {
  description = "Startup script for the Git Runner instances."
  type        = string
}

variable "git_runner_cpu_autoscaling_target" {
  description = "Target CPU utilization for Git Runner autoscaling."
  type        = number
  default     = 0.7
}

variable "git_runner_team" {
  description = "Team label for Git Runner."
  type        = string
}

variable "git_runner_repo_name" {
  description = "Repository name for the Git Runner."
  type        = string
}

variable "git_runner_repository_url" {
  description = "URL of the GitHub repository."
  type        = string
}

variable "git_runner_owner" {
  description = "Owner of the GitHub repository."
  type        = string
}
