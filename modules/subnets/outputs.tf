output "subnets" {
  description = "Map of subnet details"
  value = {
    for k, v in google_compute_subnetwork.subnet : k => {
      id          = v.id
      name        = v.name
      self_link   = v.self_link
      ip_range    = v.ip_cidr_range
      region      = v.region
      gateway     = v.gateway_address
      description = v.description
    }
  }
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = [for subnet in google_compute_subnetwork.subnet : subnet.id]
}

output "subnet_names" {
  description = "List of subnet names"
  value       = [for subnet in google_compute_subnetwork.subnet : subnet.name]
}

output "subnet_self_links" {
  description = "List of subnet self-links"
  value       = [for subnet in google_compute_subnetwork.subnet : subnet.self_link]
}

output "subnet_ip_ranges" {
  description = "Map of subnet names to IP ranges"
  value       = { for k, v in google_compute_subnetwork.subnet : v.name => v.ip_cidr_range }
}