# Network Detection Spanner Instance
# Hosts the network_devices_graph table for tracking network connections
module "network_detection_spanner" {
  source = "../../modules/cloud-fabric/spanner-instance"

  project_id = var.network_detection_spanner_project_id
  instance   = var.network_detection_spanner_instance_config
  databases  = var.network_detection_spanner_databases
}
