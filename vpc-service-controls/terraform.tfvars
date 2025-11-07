# ==============================================================================
# CONFIGURATION - Update these values for your environment
# ==============================================================================

# Find your org ID: gcloud organizations list
organization_id = ""

# Project A - Protected (storage will be restricted)
protected_project_id = ""

# Project B - Restricted (cannot access Project A's storage)
restricted_project_id = ""

# # Trusted IP ranges (corporate network, VPN, etc.)
# trusted_ip_ranges = [
#   "10.0.0.0/8",         # Corporate network
#   "203.0.113.0/24",     # VPN range
#   "198.51.100.0/24",    # Office network
# ]

# Trusted members
trusted_members = [
  "user:admin@example.com",
  "serviceAccount:demo@demo.com",
]

# Logging configuration
logs_bucket_location = "US"
enable_monitoring    = true