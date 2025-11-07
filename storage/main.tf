module "gcs_buckets" {
  source  = "terraform-google-modules/cloud-storage/google"

  project_id = var.project_id
  names      = ["my-storage-bucket"]
  prefix     = var.bucket_prefix
  location   = var.location

  # Enable versioning
  versioning = {
    my-storage-bucket = true
  }

  # Add labels (tags in GCP)
  labels = {
    environment = "production"
    team        = "data-engineering"
    cost-center = "engineering"
    managed-by  = "terraform"
    retention   = "six-years"
  }

  # Retention policy for 6 years (in seconds)
  # 6 years = 6 * 365 * 24 * 60 * 60 = 189,216,000 seconds
  retention_policy = {
    my-storage-bucket = {
      retention_period = 189216000  # 6 years in seconds
      is_locked        = false      # Set to true to lock the policy (cannot be removed)
    }
  }

  # Optional: Lifecycle rules
  lifecycle_rules = [{
    action = {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition = {
      age                   = 90  # Move to NEARLINE after 90 days
      with_state            = "LIVE"
      matches_storage_class = "STANDARD"
    }
  }]

  # Storage class
  storage_class = "STANDARD"

  # Enable uniform bucket-level access (recommended)
  bucket_policy_only = {
    my-storage-bucket = true
  }
  
  # Optional: Enable public access prevention
  public_access_prevention = "enforced"
}
