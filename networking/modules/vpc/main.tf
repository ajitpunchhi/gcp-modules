# ============================================
# VPC Module
# ============================================

resource "google_compute_network" "vpc" {
  name                            = var.network_name
  project                         = var.project_id
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes
  description                     = var.description
  mtu                             = var.mtu
}

# Allow internal communication between resources
resource "google_compute_firewall" "allow_internal" {
  count   = var.enable_internal_traffic ? 1 : 0
  name    = "${var.network_name}-allow-internal"
  project = var.project_id
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = var.internal_ranges
  priority      = 65534

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow SSH from Identity-Aware Proxy
resource "google_compute_firewall" "allow_iap_ssh" {
  count   = var.enable_iap_ssh ? 1 : 0
  name    = "${var.network_name}-allow-iap-ssh"
  project = var.project_id
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  # IAP's IP range
  source_ranges = ["35.235.240.0/20"]
  priority      = 1000

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow health checks from Google Cloud Load Balancers
resource "google_compute_firewall" "allow_health_checks" {
  count   = var.enable_health_check_firewall ? 1 : 0
  name    = "${var.network_name}-allow-health-checks"
  project = var.project_id
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
  }

  # Health check IP ranges
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  priority      = 1000

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}