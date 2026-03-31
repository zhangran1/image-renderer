# ---------------------------------------------------------------------------------------------------------------------
# Service Account for Git Runner
# ---------------------------------------------------------------------------------------------------------------------

module "git_runner_sa" {
  source     = "../../modules/cloud-fabric/iam-service-account"
  project_id = var.git_runner_project_id
  name       = var.git_runner_service_account_name

  iam_project_roles = {
    "${var.git_runner_project_id}" = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
      "roles/stackdriver.resourceMetadata.writer",
      "roles/secretmanager.secretAccessor" # Essential for ops agent
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Instance Template for Git Runner
# ---------------------------------------------------------------------------------------------------------------------

module "git_runner_template" {
  source     = "../../modules/cloud-fabric/compute-vm"
  project_id = var.git_runner_project_id
  name       = "git-runner-tpl"
  zone       = "${var.git_runner_region}-a" # Zone is required even for template but we create a global template by default

  create_template = {
    regional = false
  }

  instance_type = var.git_runner_machine_type
  
  boot_disk = {
    initialize_params = {
      image = var.git_runner_image
      size  = var.git_runner_disk_size_gb
      type  = "pd-balanced"
    }
  }

  network_interfaces = [{
    network    = var.git_runner_vpc_network
    subnetwork = var.git_runner_vpc_subnetwork
    nat        = false # Disable external IP to comply with org policy
  }]

  service_account = {
    email  = module.git_runner_sa.email
    scopes = ["cloud-platform"]
  }

  shielded_config = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata_startup_script = replace(
    replace(
      replace(var.git_runner_startup_script, "{OWNER}", var.git_runner_owner),
      "{REPO}", var.git_runner_repo_name
    ),
    "{URL}", var.git_runner_repository_url
  )

  labels = {
    env  = var.git_runner_env
    team = var.git_runner_team
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MIG for Git Runner
# ---------------------------------------------------------------------------------------------------------------------

module "git_runner_mig" {
  source            = "../../modules/cloud-fabric/compute-mig"
  project_id        = var.git_runner_project_id
  location          = "${var.git_runner_region}-a" # Zonal MIG
  name              = "git-runner-mig"
  instance_template = module.git_runner_template.template.self_link
  
  # Target size to ensure the initial VM is created
  target_size = var.git_runner_min_replicas

  # Proactive update policy to roll out template changes automatically
  update_policy = {
    type                           = "PROACTIVE"
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = 1
    max_unavailable_fixed          = 0
  }
  
  autoscaler_config = {
    max_replicas    = var.git_runner_max_replicas
    min_replicas    = var.git_runner_min_replicas
    cooldown_period = 60
    scaling_signals = {
      cpu_utilization = {
        target = var.git_runner_cpu_autoscaling_target
      }
    }
  }


}
