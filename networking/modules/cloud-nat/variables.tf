variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "router_name" {
  description = "Name of the Cloud Router"
  type        = string
}

variable "nat_name" {
  description = "Name of the Cloud NAT"
  type        = string
}

variable "source_subnetwork_ip_ranges" {
  description = "How NAT should be configured per Subnetwork"
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "nat_ip_allocate_option" {
  description = "How external IPs should be allocated"
  type        = string
  default     = "AUTO_ONLY"
}

variable "min_ports_per_vm" {
  description = "Minimum ports per VM"
  type        = number
  default     = 64
}

variable "max_ports_per_vm" {
  description = "Maximum ports per VM"
  type        = number
  default     = 65536
}

# variable "enable_endpoint_independent" {
#   description = "Enable endpoint independent mapping"
#   type        = bool
#   default     = false
# }

# variable "enable_dynamic_port_allocation" {
#   description = "Enable dynamic port allocation"
#   type        = bool
#   default     = false
# }

variable "log_config_enable" {
  description = "Enable NAT logging"
  type        = bool
  default     = true
}

variable "log_config_filter" {
  description = "Filter for NAT logs"
  type        = string
  default     = "ALL"
}