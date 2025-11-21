variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "network_id" {
  description = "ID of the VPC network"
  type        = string
}

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
}