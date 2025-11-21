output "psc_address" {
  description = "The allocated IP address"
  value       = google_compute_global_address.private_service_connect.address
}

output "psc_address_name" {
  description = "Name of the PSC address"
  value       = google_compute_global_address.private_service_connect.name
}

output "psc_connection_id" {
  description = "ID of the service networking connection"
  value       = google_service_networking_connection.private_vpc_connection.id
}