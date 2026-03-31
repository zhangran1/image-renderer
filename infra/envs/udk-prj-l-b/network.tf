# ---------------------------------------------------------------------------------------------------------------------
# Cloud NAT for Git Runner
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_router" "router" {
  name    = "git-runner-router"
  region  = var.git_runner_region
  project = var.git_runner_project_id
  network = var.git_runner_vpc_network
}

resource "google_compute_router_nat" "nat" {
  name                               = "git-runner-nat"
  router                             = google_compute_router.router.name
  region                             = var.git_runner_region
  project                            = var.git_runner_project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = var.git_runner_vpc_subnetwork
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

