resource "google_compute_network" "dws_network" {
  name                    = "dws-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "test_sub" {
  name          = "test-sub"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.dws_network.id

  # Security: Enable flow logs for better visibility and auditing
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  private_ip_google_access = true
}

# Allow Dataflow workers to communicate with each other
resource "google_compute_firewall" "allow_dataflow_internal" {
  name    = "allow-dataflow-internal"
  network = google_compute_network.dws_network.name

  allow {
    protocol = "tcp"
    ports    = ["12345-12346"]
  }

  source_tags = ["dataflow"]
  target_tags = ["dataflow"]
}
