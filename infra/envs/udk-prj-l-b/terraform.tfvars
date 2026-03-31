provider_project_id = "udk-prj-l-b-491204"
provider_region     = "us-central1"

#-------------------------------------------------------------------------------------
# GCS Configuration (Cloud Functions Source)
#-------------------------------------------------------------------------------------
cloud_functions_bucket_project_id = "udk-prj-l-b-491204"
cloud_functions_bucket_region     = "us-central1"
cloud_functions_bucket_env        = "dev"
cloud_functions_bucket_team       = "data-platform"
cloud_functions_bucket_name       = "udk-prj-l-b-491204-cf"
cloud_functions_bucket_versioning = true
cloud_functions_bucket_storage_class = "STANDARD"
cloud_functions_bucket_iam        = {}

#-------------------------------------------------------------------------------------
# Cloud Function Configuration
#-------------------------------------------------------------------------------------
anomaly_detection_func_project_id           = "udk-prj-l-b-491204"
anomaly_detection_func_region               = "us-central1"
anomaly_detection_func_env                  = "dev"
anomaly_detection_func_team                 = "data-science"
anomaly_detection_func_name                 = "anomaly-detection-func"
anomaly_detection_func_bucket_name          = "udk-prj-l-b-491204-cf"
anomaly_detection_func_entry_point          = "handle_request"
anomaly_detection_func_min_instances        = 0
anomaly_detection_func_max_instances        = 10
anomaly_detection_func_timeout_seconds      = 3000
anomaly_detection_func_memory_mb            = 1024
anomaly_detection_func_cpu                  = "1"
anomaly_detection_func_runtime              = "python310"
anomaly_detection_func_vpc_network          = "projects/udk-prj-l-b-491204/global/networks/dws-network"
anomaly_detection_func_vpc_subnetwork       = "projects/udk-prj-l-b-491204/regions/us-central1/subnetworks/test-sub"
anomaly_detection_func_sa_project_id        = "udk-prj-l-b-491204"
anomaly_detection_func_sa_target_project_id = "udk-prj-l-b-491204" 
anomaly_detection_func_sa_name              = "anomaly-func-sa"

#-------------------------------------------------------------------------------------
# Daily APIC Scheduler Job Configuration
#-------------------------------------------------------------------------------------
daily_apic_job_project_id = "udk-prj-l-b-491204"
daily_apic_job_region     = "us-central1"
daily_apic_job_name       = "daily-apic-job"
daily_apic_job_schedule   = "*/10 * * * *"
daily_apic_job_sa_project_id = "udk-prj-l-b-491204"
daily_apic_job_sa_name       = "daily-apic-job-sa"
daily_apic_job_sa_target_project_id                 = "udk-prj-l-b-491204"
daily_apic_job_env  = "dev"
daily_apic_job_team = "data-science"

#-------------------------------------------------------------------------------------
# Workflow Configuration
#-------------------------------------------------------------------------------------
anomaly_detection_workflow_sa_project_id = "udk-prj-l-b-491204"
anomaly_detection_workflow_sa_name       = "net-anomaly-detect-wf-sa"
anomaly_detection_workflow_project_id    = "udk-prj-l-b-491204"
anomaly_detection_workflow_region        = "us-central1"
anomaly_detection_workflow_name          = "network-anomaly-detection-wf"
anomaly_detection_workflow_description   = "Orchestrates Network Anomaly Detection via Cloud Functions"
anomaly_detection_workflow_env           = "dev"
anomaly_detection_workflow_team          = "data-science"
anomaly_detection_scheduler_sa_name              = "anomaly-detect-sched-sa"
anomaly_detection_scheduler_sa_project_id        = "udk-prj-l-b-491204"
anomaly_detection_scheduler_sa_target_project_id = "udk-prj-l-b-491204"
anomaly_detection_workflow_trigger_name      = "anomaly_detect_scheduler"
anomaly_detection_workflow_trigger_cron      = "*/10 * * * *"
anomaly_detection_workflow_trigger_time_zone = "America/New_York"
anomaly_detection_workflow_trigger_deadline  = "1800s"
anomaly_detection_workflow_sa_target_project_id = "udk-prj-l-b-491204"
anomaly_detection_workflow_bq_dataset        = "model_ops"
anomaly_detection_workflow_bq_table          = "audit_log"
anomaly_detection_workflow_bq_model_name     = "network_anomaly_model"
anomaly_detection_workflow_time_column       = "timestamp"
anomaly_detection_workflow_value_column      = "value"
anomaly_detection_workflow_redis_host        = "10.0.0.5"
anomaly_detection_workflow_redis_port        = 6379

#-------------------------------------------------------------------------------------
#  Cloud Run Configuration
#-------------------------------------------------------------------------------------
anomaly_detection_service_name                 = "anomaly-detection-service"
anomaly_detection_service_project_id           = "udk-prj-l-b-491204"
anomaly_detection_service_region               = "us-central1"
anomaly_detection_service_sa_name              = "anomaly-det-svc-sa"
anomaly_detection_service_sa_project_id        = "udk-prj-l-b-491204"
anomaly_detection_service_sa_target_project_id = "udk-prj-l-b-491204"
anomaly_detection_service_env                  = "dev"
anomaly_detection_service_team                 = "network-security"
anomaly_detection_service_min_instances = 1
anomaly_detection_service_max_instances = 5
anomaly_detection_service_timeout       = "60s"
anomaly_detection_service_cpu           = "1000m"
anomaly_detection_service_memory        = "1Gi"
anomaly_detection_service_image = "us-docker.pkg.dev/cloudrun/container/hello"
anomaly_detection_service_vpc_access = {
  egress  = "PRIVATE_RANGES_ONLY"
  network = "projects/udk-prj-l-b-491204/global/networks/dws-network"
  subnet  = "projects/udk-prj-l-b-491204/regions/us-central1/subnetworks/test-sub"
}

# ---------------------------------------------------------------------------------------------------------------------
# Git Runner Configuration
# ---------------------------------------------------------------------------------------------------------------------

git_runner_owner                = "zhangran1"
git_runner_repo_name            = "image-renderer"
git_runner_repository_url       = "https://github.com/zhangran1/image-renderer"
git_runner_project_id           = "udk-prj-l-b-491204"
git_runner_region               = "us-central1"
git_runner_env                  = "dev"
git_runner_team                 = "devops"
git_runner_vpc_network          = "projects/udk-prj-l-b-491204/global/networks/dws-network"
git_runner_vpc_subnetwork       = "projects/udk-prj-l-b-491204/regions/us-central1/subnetworks/test-sub"
git_runner_min_replicas         = 1
git_runner_max_replicas         = 3
git_runner_cpu_autoscaling_target           = 0.7

# git_runner_startup_script = <<-EOT
# #!/bin/bash
# # Install dependencies
# sudo apt-get update && sudo apt-get install -y jq curl

# PAT_TOKEN=$(gcloud secrets versions access latest --secret="GITHUB_PAT")

# # REG_TOKEN=$(curl -X POST -H "Authorization: Bearer $PAT_TOKEN" \
# #   -H "Accept: application/vnd.github.v3+json" \
# #   https://api.github.com/repos/{OWNER}/{REPO}/actions/runners/registration-token | jq -r .token)

# REG_TOKEN=$( curl -L -X POST -H "Authorization: Bearer $PAT_TOKEN" -H "Accept: application/vnd.github.v3+json"    https://api.github.com/repos/zhangran1/image-renderer/actions/runners/registration-token | jq -r .token)

# # # These placeholders are replaced by Terraform in compute.tf
# # # REPO_URL="{URL}"
# # REPO_URL="https://github.com/zhangran1/image-renderer"
# # OWNER="{OWNER}"
# # OWNER="zhangran1"
# # # REPO="{REPO}"
# # REPO="https://github.com/zhangran1/image-renderer"



# # Download the latest runner package
# curl -o actions-runner-linux-x64-2.332.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.332.0/actions-runner-linux-x64-2.332.0.tar.gz
# # Extract the installer
# tar xzf ./actions-runner-linux-x64-2.332.0.tar.gz
# # Create the runner and start the configuration experience
# export RUNNER_ALLOW_RUNASROOT=1
# VM_NAME=$(hostname)
# # ./config.sh --url {URL} --token $REG_TOKEN --name "$VM_NAME" --labels self-hosted --unattended
# ./config.sh --url "https://github.com/zhangran1/image-renderer" --token $REG_TOKEN --name "$VM_NAME" --labels self-hosted --unattended

# # Install and run as service
# sudo ./svc.sh install
# sudo ./svc.sh start
# EOT

git_runner_startup_script = <<-EOT
#!/bin/bash
set -e  # Exit on error

# 1. Create a dedicated directory for the runner
mkdir -p /actions-runner && cd /actions-runner

# 2. Install dependencies
sudo apt-get update && sudo apt-get install -y jq curl libicu-dev

# 3. Get the token from Secret Manager
# Note: Ensure the Service Account has roles/secretmanager.secretAccessor
PAT_TOKEN=$(gcloud secrets versions access latest --secret="GITHUB_PAT")

# 4. Get Registration Token
REG_TOKEN=$(curl -L -X POST \
  -H "Authorization: Bearer $PAT_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/zhangran1/image-renderer/actions/runners/registration-token | jq -r .token)

# 5. Download and Extract (Cleanly)
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# 6. Configure the runner
# We use --replace to handle MIG instances that might reboot/recycle
export RUNNER_ALLOW_RUNASROOT=1
./config.sh --url "https://github.com/zhangran1/image-renderer" \
            --token "$REG_TOKEN" \
            --name "$(hostname)" \
            --labels self-hosted \
            --unattended \
            --replace

# 7. Install and start as a systemd service
./svc.sh install
./svc.sh start
EOT
