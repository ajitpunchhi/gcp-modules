variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network_id" {
  description = "The VPC network ID"
  type        = string
}

variable "private_service_connect_name" {
  description = "Name of the Private Service Connect address"
  type        = string
}

variable "address" {
  description = "IP address for Private Service Connect"
  type        = string
  default     = null
}

variable "address_type" {
  description = "Address type"
  type        = string
  default     = "INTERNAL"
}

variable "purpose" {
  description = "Purpose of the address"
  type        = string
  default     = "VPC_PEERING"
}

variable "prefix_length" {
  description = "Prefix length"
  type        = number
  default     = 16
}

variable "description" {
  description = "Description"
  type        = string
  default     = "Private Service Connect for Google APIs"
}