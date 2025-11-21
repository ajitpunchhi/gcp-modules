variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network_id" {
  description = "The VPC network ID"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "private_zones" {
  description = "List of private DNS zones"
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