# ==============================================================================
# CONFIGURATION - Update these values for your environment
# ==============================================================================

names = "ajit-test-bucket-001"
bucket_prefix = "terraform-test-1"
location = "US"
project_id = "hc-test-app-475301"
versioning = true
labels = {
  environment = "production"
  team        = "data-engineering"
  cost-center = "engineering"
  managed-by  = "terraform"
  retention   = "six-years"
}
retention_period = 189216000  # 6 years in seconds
lifecycle_rules = [{
  action = {
    type          = "SetStorageClass"
    storage_class = "NEARLINE"
  }
  condition = {
    age                   = 90  # Move to NEARLINE after 90 days
    with_state            = "LIVE"
    matches_storage_class = "STANDARD"  }
}
]
storage_class = "standard"
# ==============================================================================
# END OF CONFIGURATION