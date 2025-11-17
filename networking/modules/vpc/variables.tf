variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "routing_mode" {
  description = "Network routing mode"
  type        = string
  default     = "GLOBAL"
}

variable "description" {
  description = "Description of the VPC"
  type        = string
  default     = "Managed by Terraform"
}

variable "delete_default_routes" {
  description = "Whether to delete default routes"
  type        = bool
  default     = false
}

variable "mtu" {
  description = "Maximum Transmission Unit in bytes"
  type        = number
  default     = 1460
}

variable "enable_internal_traffic" {
  description = "Enable internal traffic firewall rule"
  type        = bool
  default     = true
}

variable "internal_ranges" {
  description = "CIDR ranges for internal traffic"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "enable_iap_ssh" {
  description = "Enable IAP SSH access"
  type        = bool
  default     = true
}

variable "enable_health_check_firewall" {
  description = "Enable health check firewall rule"
  type        = bool
  default     = true
}