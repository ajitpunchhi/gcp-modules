output "router_id" {
  description = "ID of the Cloud Router"
  value       = google_compute_router.router.id
}

output "router_name" {
  description = "Name of the Cloud Router"
  value       = google_compute_router.router.name
}

output "nat_id" {
  description = "ID of the Cloud NAT"
  value       = google_compute_router_nat.nat.id
}

output "nat_name" {
  description = "Name of the Cloud NAT"
  value       = google_compute_router_nat.nat.name
}