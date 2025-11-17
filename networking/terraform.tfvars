# ============================================
# Terraform Variables Configuration
# ============================================

# ===== Project Configuration =====
project_id = ""
region     = ""

# ===== VPC Configuration =====
network_name              = ""
routing_mode              = "GLOBAL"
vpc_description           = "Main production VPC network"
delete_default_routes     = false
mtu                       = 1460
enable_internal_traffic   = true
internal_ranges           = ["", "", ""]
enable_iap_ssh            = true
enable_health_check_firewall = true

# ===== Subnet Configuration =====
subnets = [
  {
    subnet_name           = "subnet-us-central1-private"
    subnet_ip             = ""
    subnet_region         = "us-central1"
    subnet_private_access = true
    subnet_flow_logs      = true
    description           = "Private subnet for application workloads"
    secondary_ranges = [
      {
        range_name    = "pods"
        ip_cidr_range = ""
      },
      {
        range_name    = "services"
        ip_cidr_range = ""
      }
    ]
  },
  {
    subnet_name           = "subnet-us-east1-private"
    subnet_ip             = ""
    subnet_region         = "us-east1"
    subnet_private_access = true
    subnet_flow_logs      = true
    description           = "Private subnet for multi-region deployment"
    secondary_ranges = [
      {
        range_name    = "pods"
        ip_cidr_range = ""
      },
      {
        range_name    = "services"
        ip_cidr_range = ""
      }
    ]
  },
  {
    subnet_name           = ""
    subnet_ip             = ""
    subnet_region         = "us-central1"
    subnet_private_access = false
    subnet_flow_logs      = false
    description           = ""
    purpose               = "REGIONAL_MANAGED_PROXY"
    role                  = "ACTIVE"
  }
]

# ===== Cloud NAT Configuration =====
nat_router_name                    = ""
nat_name                           = ""
nat_source_subnetwork_ip_ranges    = "ALL_SUBNETWORKS_ALL_IP_RANGES"
nat_ip_allocate_option             = "AUTO_ONLY"
nat_min_ports_per_vm               = 64
nat_max_ports_per_vm               = 65536
nat_enable_endpoint_independent    = true
nat_enable_dynamic_port_allocation = true
nat_log_config_enable              = true
nat_log_config_filter              = "ERRORS_ONLY"

# ===== Private Service Connect Configuration =====
private_service_connect_name = "google-apis-psc"
psc_address                  = null  # Auto-allocate
psc_address_type             = "INTERNAL"
psc_purpose                  = "VPC_PEERING"
psc_prefix_length            = 16
psc_description              = "IP range for Private Service Connect to Google APIs"

# ===== DNS Configuration =====
enable_googleapis_zone = true
enable_gcr_zone        = true
enable_pkg_dev_zone    = true

private_dns_zones = [
  {
    name        = "internal-zone"
    dns_name    = "internal.example.com."
    description = "Internal DNS zone for private services"
    records = [
      {
        name    = "app"
        type    = "A"
        ttl     = 300
        rrdatas = ["10.10.10.10"]
      },
      {
        name    = "db"
        type    = "A"
        ttl     = 300
        rrdatas = ["10.10.10.20"]
      }
    ]
  }
]

# ===== Resource Labels =====
labels = {
  managed_by  = "terraform"
  environment = "production"
  team        = "platform"
  cost_center = "engineering"
}