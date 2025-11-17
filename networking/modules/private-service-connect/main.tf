# ============================================
# Private Service Connect Module
# ============================================

# Allocate IP range for Private Service Connect
resource "google_compute_global_address" "private_service_connect" {
  name          = var.private_service_connect_name
  project       = var.project_id
  purpose       = var.purpose
  address_type  = var.address_type
  prefix_length = var.prefix_length
  address       = var.address
  network       = var.network_id
  description   = var.description
}

# Create VPC peering connection to Google APIs
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_connect.name]
}