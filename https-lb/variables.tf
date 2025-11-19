# Variables for HTTPS Load Balancer Module

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

# SSL Certificate Configuration
variable "use_managed_ssl" {
  description = "Use Google-managed SSL certificate (true) or self-managed (false)"
  type        = bool
  default     = true
}

variable "managed_ssl_domains" {
  description = "List of domains for managed SSL certificate"
  type        = list(string)
  default     = []
}

variable "ssl_certificate" {
  description = "SSL certificate content (for self-managed SSL)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ssl_private_key" {
  description = "SSL private key content (for self-managed SSL)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ssl_policy_name" {
  description = "Name of SSL policy to apply (optional)"
  type        = string
  default     = ""
}

# Backend Service Configuration
variable "backend_protocol" {
  description = "Protocol for backend service (HTTP, HTTPS, HTTP2)"
  type        = string
  default     = "HTTP"
}

variable "backend_port_name" {
  description = "Named port for backend service"
  type        = string
  default     = "http"
}

variable "backend_timeout_sec" {
  description = "Backend service timeout in seconds"
  type        = number
  default     = 30
}

variable "backend_groups" {
  description = "List of backend instance groups"
  type = list(object({
    group           = string
    balancing_mode  = string
    capacity_scaler = number
    max_utilization = number
  }))
  default = []
}

# Health Check Configuration
variable "health_check_config" {
  description = "Health check configuration"
  type = object({
    protocol            = string
    port                = number
    request_path        = string
    check_interval_sec  = number
    timeout_sec         = number
    healthy_threshold   = number
    unhealthy_threshold = number
  })
  default = {
    protocol            = "HTTP"
    port                = 80
    request_path        = "/"
    check_interval_sec  = 5
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# CDN Configuration
variable "enable_cdn" {
  description = "Enable Cloud CDN"
  type        = bool
  default     = false
}

variable "cdn_config" {
  description = "CDN configuration"
  type = object({
    cache_mode                   = string
    client_ttl                   = number
    default_ttl                  = number
    max_ttl                      = number
    negative_caching             = bool
    serve_while_stale            = number
    signed_url_cache_max_age_sec = number
    cache_key_policy = object({
      include_host           = bool
      include_protocol       = bool
      include_query_string   = bool
      query_string_whitelist = list(string)
    })
  })
  default = {
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
}

# URL Mapping Configuration
variable "host_rules" {
  description = "List of host rules for URL mapping"
  type = list(object({
    hosts        = list(string)
    path_matcher = string
  }))
  default = []
}

variable "path_matchers" {
  description = "List of path matchers for URL mapping"
  type = list(object({
    name = string
    path_rules = list(object({
      paths   = list(string)
      service = string
    }))
  }))
  default = []
}

# HTTP to HTTPS Redirect
variable "enable_http_redirect" {
  description = "Enable HTTP to HTTPS redirect"
  type        = bool
  default     = true
}

# Logging Configuration
variable "enable_logging" {
  description = "Enable access logging"
  type        = bool
  default     = false
}

variable "log_sample_rate" {
  description = "Sample rate for access logs (0.0 to 1.0)"
  type        = number
  default     = 1.0
}
