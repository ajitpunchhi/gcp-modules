# Example terraform.tfvars file for HTTPS Load Balancer Module
# Copy this file and customize for your needs

# Basic Configuration
name       = ""
project_id = ""

# SSL Certificate Configuration
# Option 1: Use Google-managed SSL certificate (recommended)
use_managed_ssl     = true
managed_ssl_domains = ["example.com", "www.example.com"]

# Option 2: Use self-managed SSL certificate (uncomment to use)
# use_managed_ssl = false
# ssl_certificate = file("path/to/certificate.crt")
# ssl_private_key = file("path/to/private.key")

# Backend Service Configuration
backend_protocol    = "HTTPS"
backend_port_name   = "https"
backend_timeout_sec = 30

# Example backend groups (replace with your actual instance group IDs)
backend_groups = [
  {
    group           = "https://www.googleapis.com/compute/v1/projects/my-project/zones/us-central1-a/instanceGroups/my-instance-group"
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
    max_utilization = 0.8
  }
]

# Health Check Configuration
health_check_config = {
  protocol            = "HTTP"
  port                = 80
  request_path        = "/health"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# CDN Configuration
enable_cdn = true
cdn_config = {
  cache_mode                   = "CACHE_ALL_STATIC"
  client_ttl                   = 3600
  default_ttl                  = 3600
  max_ttl                      = 86400
  negative_caching             = true
  serve_while_stale            = 86400
  signed_url_cache_max_age_sec = 0
  cache_key_policy = {
    include_host           = true
    include_protocol       = true
    include_query_string   = true
    query_string_whitelist = []
  }
}

# URL Mapping Configuration (optional)
# Example: Route different paths to different services
host_rules = [
  {
    hosts        = ["example.com", "www.example.com"]
    path_matcher = "main-paths"
  }
]

path_matchers = [
  {
    name = "main-paths"
    path_rules = [
      {
        paths   = ["/api/*"]
        service = "" # Uses default backend service
      },
      {
        paths   = ["/static/*"]
        service = "" # Can specify different backend service ID here
      }
    ]
  }
]

# HTTP to HTTPS Redirect
enable_http_redirect = true

# Logging Configuration
enable_logging  = true
log_sample_rate = 1.0
