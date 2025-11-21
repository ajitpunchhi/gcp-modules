# ============================================
# Root Module Variables
# ============================================

# ===== Project & Region =====
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources"
  type        = string
  default     = "us-central1"
}

# ===== VPC Variables =====
variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "routing_mode" {
  description = "Network routing mode (REGIONAL or GLOBAL)"
  type        = string
  default     = "GLOBAL"
  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "Routing mode must be REGIONAL or GLOBAL."
  }
}

variable "vpc_description" {
  description = "Description of the VPC"
  type        = string
  default     = "Managed by Terraform"
}

variable "delete_default_routes" {
  description = "Whether to delete default routes on VPC creation"
  type        = bool
  default     = false
}

variable "mtu" {
  description = "Maximum Transmission Unit in bytes"
  type        = number
  default     = 1460
  validation {
    condition     = var.mtu >= 1300 && var.mtu <= 8896
    error_message = "MTU must be between 1300 and 8896."
  }
}

variable "enable_internal_traffic" {
  description = "Enable firewall rule for internal traffic"
  type        = bool
  default     = true
}

variable "internal_ranges" {
  description = "CIDR ranges for internal traffic firewall rule"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "enable_iap_ssh" {
  description = "Enable SSH access via Identity-Aware Proxy"
  type        = bool
  default     = true
}

variable "enable_health_check_firewall" {
  description = "Enable health check firewall rule"
  type        = bool
  default     = true
}

# ===== Subnet Variables =====
variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    subnet_name               = string
    subnet_ip                 = string
    subnet_region             = string
    subnet_private_access     = optional(bool, true)
    subnet_flow_logs          = optional(bool, true)
    subnet_flow_logs_interval = optional(string, "INTERVAL_5_SEC")
    subnet_flow_logs_sampling = optional(number, 0.5)
    subnet_flow_logs_metadata = optional(string, "INCLUDE_ALL_METADATA")
    description               = optional(string, "Managed by Terraform")
    purpose                   = optional(string, null)
    role                      = optional(string, null)
    secondary_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
    log_config = optional(object({
      aggregation_interval = optional(string, "INTERVAL_5_SEC")
      flow_sampling        = optional(number, 0.5)
      metadata             = optional(string, "INCLUDE_ALL_METADATA")
      metadata_fields      = optional(list(string), [])
      filter_expr          = optional(string, null)
    }), null)
  }))
  default = []
}

# ===== Cloud NAT Variables =====
variable "nat_router_name" {
  description = "Name of the Cloud Router for NAT"
  type        = string
  default     = null
}

variable "nat_name" {
  description = "Name of the Cloud NAT"
  type        = string
  default     = null
}

variable "nat_source_subnetwork_ip_ranges" {
  description = "How NAT should be configured per Subnetwork"
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "nat_ip_allocate_option" {
  description = "How external IPs should be allocated for NAT"
  type        = string
  default     = "AUTO_ONLY"
}

variable "nat_min_ports_per_vm" {
  description = "Minimum number of ports allocated to a VM"
  type        = number
  default     = 64
}

variable "nat_max_ports_per_vm" {
  description = "Maximum number of ports allocated to a VM"
  type        = number
  default     = 65536
}

variable "nat_enable_endpoint_independent" {
  description = "Enable endpoint independent mapping"
  type        = bool
  default     = false
}

variable "nat_enable_dynamic_port_allocation" {
  description = "Enable dynamic port allocation"
  type        = bool
  default     = true
}

variable "nat_log_config_enable" {
  description = "Enable logging for Cloud NAT"
  type        = bool
  default     = true
}

variable "nat_log_config_filter" {
  description = "Filter for NAT logs"
  type        = string
  default     = "ALL"
}

# ===== Private Service Connect Variables =====
variable "private_service_connect_name" {
  description = "Name of the Private Service Connect"
  type        = string
  default     = null
}

variable "psc_address" {
  description = "IP address for Private Service Connect"
  type        = string
  default     = null
}

variable "psc_address_type" {
  description = "Address type for Private Service Connect"
  type        = string
  default     = "INTERNAL"
}

variable "psc_purpose" {
  description = "Purpose of the Private Service Connect address"
  type        = string
  default     = "VPC_PEERING"
}

variable "psc_prefix_length" {
  description = "Prefix length for Private Service Connect"
  type        = number
  default     = 16
}

variable "psc_description" {
  description = "Description for Private Service Connect"
  type        = string
  default     = "Private Service Connect for Google APIs"
}

# ===== DNS Variables =====
variable "private_dns_zones" {
  description = "List of private DNS zones to create"
  type = list(object({
    name        = string
    dns_name    = string
    description = optional(string, "Managed by Terraform")
    records = optional(list(object({
      name    = string
      type    = string
      ttl     = number
      rrdatas = list(string)
    })), [])
  }))
  default = []
}

variable "enable_googleapis_zone" {
  description = "Enable private DNS zone for googleapis.com"
  type        = bool
  default     = true
}

variable "enable_gcr_zone" {
  description = "Enable private DNS zone for gcr.io"
  type        = bool
  default     = true
}

variable "enable_pkg_dev_zone" {
  description = "Enable private DNS zone for pkg.dev"
  type        = bool
  default     = true
}

# ===== Tags =====
variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    managed_by  = "terraform"
    environment = "production"
  }
}