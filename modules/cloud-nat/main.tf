# ============================================
# Cloud NAT Module
# ============================================

resource "google_compute_router" "router" {
  name    = var.router_name
  project = var.project_id
  region  = var.region
  network = var.network_name

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges

  min_ports_per_vm                   = var.min_ports_per_vm
  max_ports_per_vm                   = var.max_ports_per_vm
  # enable_endpoint_independent_mapping = var.enable_endpoint_independent
  # enable_dynamic_port_allocation     = var.enable_dynamic_port_allocation

  # Logging configuration
  log_config {
    enable = var.log_config_enable
    filter = var.log_config_filter
  }
}