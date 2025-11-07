# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     =   ""
}

variable "names" {
  description = "Name of the bucket (must be globally unique)"
  type        = string
  default     = ""  
}

variable "bucket_prefix" {
  description = "Prefix for bucket name (must be globally unique)"
  type        = string
  default     = ""
}

variable "location" {
  description = "The location of the bucket"
  type        = string
  default     = ""  # Options: US, EU, ASIA, or specific regions like us-central1
}

variable "versioning" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels (tags) to apply to the bucket"
  type        = map(string)
  default     = {
    environment = ""
    team        = ""
    cost-center = ""
    managed-by  = ""
    retention   = ""
  }
}

variable "retention_period" {
  description = "Retention period for the bucket in seconds"
  type        = number
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket"
  type        = list(object({
    action = object({
      type          = string
      storage_class = string
    })
    condition = object({
      age                   = number
      with_state            = string
      matches_storage_class = string
    })
  }))
  default     = []
  
}
variable "storage_class" {
  description = "Storage class of the bucket"
  type        = string
  default     = ""  # Options: STANDARD, NEARLINE, COLDLINE, ARCHIVE
}