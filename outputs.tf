# ============================================
# Root Module Outputs
# ============================================

# ===== VPC Outputs =====
output "network_id" {
  description = "The ID of the VPC network"
  value       = module.vpc.network_id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = module.vpc.network_name
}

output "network_self_link" {
  description = "The self-link of the VPC network"
  value       = module.vpc.network_self_link
}

# ===== Subnet Outputs =====
output "subnets" {
  description = "Map of subnet details"
  value       = module.subnets.subnets
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = module.subnets.subnet_ids
}

output "subnet_names" {
  description = "List of subnet names"
  value       = module.subnets.subnet_names
}

output "subnet_self_links" {
  description = "List of subnet self-links"
  value       = module.subnets.subnet_self_links
}

output "subnet_ip_ranges" {
  description = "Map of subnet names to IP ranges"
  value       = module.subnets.subnet_ip_ranges
}

# ===== Cloud NAT Outputs =====
output "nat_id" {
  description = "The ID of the Cloud NAT"
  value       = module.cloud_nat.nat_id
}

output "nat_name" {
  description = "The name of the Cloud NAT"
  value       = module.cloud_nat.nat_name
}

output "router_id" {
  description = "The ID of the Cloud Router"
  value       = module.cloud_nat.router_id
}

output "router_name" {
  description = "The name of the Cloud Router"
  value       = module.cloud_nat.router_name
}

# ===== Private Service Connect Outputs =====
output "psc_address" {
  description = "The allocated IP address for Private Service Connect"
  value       = module.private_service_connect.psc_address
}

output "psc_address_name" {
  description = "The name of the Private Service Connect address"
  value       = module.private_service_connect.psc_address_name
}

# ===== DNS Outputs =====
output "dns_zones" {
  description = "Map of DNS zone details"
  value       = module.dns.dns_zones
}

output "dns_zone_names" {
  description = "List of DNS zone names"
  value       = module.dns.dns_zone_names
}

output "googleapis_zone_name" {
  description = "Name of the googleapis.com private DNS zone"
  value       = module.dns.googleapis_zone_name
}

output "gcr_zone_name" {
  description = "Name of the gcr.io private DNS zone"
  value       = module.dns.gcr_zone_name
}

output "pkg_dev_zone_name" {
  description = "Name of the pkg.dev private DNS zone"
  value       = module.dns.pkg_dev_zone_name
}