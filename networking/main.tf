# ============================================
# Root Module - GCP Networking Module Suite
# ============================================

# ============================================
# VPC Module
# ============================================
module "vpc" {
  source = "./modules/vpc"

  project_id                    = var.project_id
  network_name                  = var.network_name
  routing_mode                  = var.routing_mode
  description                   = var.vpc_description
  delete_default_routes         = var.delete_default_routes
  mtu                           = var.mtu
  enable_internal_traffic       = var.enable_internal_traffic
  internal_ranges               = var.internal_ranges
  enable_iap_ssh                = var.enable_iap_ssh
  enable_health_check_firewall  = var.enable_health_check_firewall
}

# ============================================
# Subnets Module
# ============================================
module "subnets" {
source = "./modules/subnets"
project_id = var.project_id
network_name = module.vpc.network_name
network_id = module.vpc.network_id
subnets = var.subnets

depends_on = [ module.vpc ]
}

# ============================================
# Cloud NAT Module
# ============================================
module "cloud_nat" {
  source = "./modules/cloud-nat"

  project_id                     = var.project_id
  region                         = var.region
  network_name                   = module.vpc.network_name
  router_name                    = var.nat_router_name
  nat_name                       = var.nat_name
  source_subnetwork_ip_ranges    = var.nat_source_subnetwork_ip_ranges
  nat_ip_allocate_option         = var.nat_ip_allocate_option
  min_ports_per_vm               = var.nat_min_ports_per_vm
  max_ports_per_vm               = var.nat_max_ports_per_vm
  # enable_endpoint_independent    = var.nat_enable_endpoint_independent
  # enable_dynamic_port_allocation = var.nat_enable_dynamic_port_allocation
  log_config_enable              = var.nat_log_config_enable
  log_config_filter              = var.nat_log_config_filter

  depends_on = [module.vpc, module.subnets]
}

# ============================================
# Private Service Connect Module
# ============================================
module "private_service_connect" {
  source = "./modules/private-service-connect"

  project_id                   = var.project_id
  network_id                   = module.vpc.network_id
  private_service_connect_name = var.private_service_connect_name
  address                      = var.psc_address
  address_type                 = var.psc_address_type
  purpose                      = var.psc_purpose
  prefix_length                = var.psc_prefix_length
  description                  = var.psc_description

  depends_on = [module.vpc]
}

# ============================================
# Private DNS Module
# ============================================
module "dns" {
  source = "./modules/dns"

  project_id              = var.project_id
  network_id              = module.vpc.network_id
  network_name            = module.vpc.network_name
  private_zones           = var.private_dns_zones
  enable_googleapis_zone  = var.enable_googleapis_zone
  enable_gcr_zone         = var.enable_gcr_zone
  enable_pkg_dev_zone     = var.enable_pkg_dev_zone

  depends_on = [module.vpc, module.private_service_connect]
}