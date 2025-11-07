# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================

variable "organization_id" {
  description = "GCP Organization ID where VPC Service Controls will be applied"
  type        = string
  
  validation {
    condition     = can(regex("^[0-9]+$", var.organization_id))
    error_message = "Organization ID must be numeric."
  }
}

variable "protected_project_id" {
  description = "Project ID for Project A (protected - storage access will be restricted)"
  type        = string
  
  validation {
    condition     = length(var.protected_project_id) > 0
    error_message = "Protected project ID cannot be empty."
  }
}

variable "restricted_project_id" {
  description = "Project ID for Project B (restricted - cannot access Project A's storage)"
  type        = string
  
  validation {
    condition     = length(var.restricted_project_id) > 0
    error_message = "Restricted project ID cannot be empty."
  }
}

# ==============================================================================
# OPTIONAL VARIABLES WITH DEFAULTS
# ==============================================================================

# variable "trusted_ip_ranges" {
#   description = "List of IP ranges (CIDR) allowed to access protected resources"
#   type        = list(string)
#   default = [
#     "10.0.0.0/8",      # RFC1918 - Private network
#     "172.16.0.0/12",   # RFC1918 - Private network
#     "192.168.0.0/16",  # RFC1918 - Private network
#   ]
  
#   validation {
#     condition     = alltrue([for ip in var.trusted_ip_ranges : can(cidrhost(ip, 0))])
#     error_message = "All IP ranges must be valid CIDR notation."
#   }
# }

variable "trusted_members" {
  description = "List of trusted users/service accounts allowed to access protected resources"
  type        = list(string)
  default     = []
  
  # Example format:
  # [
  #   "user:admin@example.com",
  #   "serviceAccount:sa@project.iam.gserviceaccount.com",
  #   "group:team@example.com",
  # ]
}

variable "logs_bucket_location" {
  description = "GCS location for VPC SC violation logs"
  type        = string
  default     = "US"
  
  validation {
    condition     = contains(["US", "EU", "ASIA"], var.logs_bucket_location)
    error_message = "Location must be US, EU, or ASIA."
  }
}

variable "enable_monitoring" {
  description = "Enable monitoring and logging for VPC SC violations"
  type        = bool
  default     = true
}