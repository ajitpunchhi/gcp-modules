# HTTPS Load Balancer Terraform Module
# Supports SSL termination, URL mapping, backend services, health checks, and CDN

# Global Static IP Address
resource "google_compute_global_address" "default" {
  name         = "${var.name}-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

# Managed SSL Certificate (if enabled)
resource "google_compute_managed_ssl_certificate" "default" {
  count = var.use_managed_ssl ? 1 : 0
  name  = "${var.name}-cert"

  managed {
    domains = var.managed_ssl_domains
  }
}

# Self-Managed SSL Certificate (if enabled)
resource "google_compute_ssl_certificate" "default" {
  count       = var.use_managed_ssl ? 0 : 1
  name        = "${var.name}-cert"
  private_key = var.ssl_private_key
  certificate = var.ssl_certificate
}

# Health Check
resource "google_compute_health_check" "default" {
  name                = "${var.name}-health-check"
  check_interval_sec  = var.health_check_config.check_interval_sec
  timeout_sec         = var.health_check_config.timeout_sec
  healthy_threshold   = var.health_check_config.healthy_threshold
  unhealthy_threshold = var.health_check_config.unhealthy_threshold

  dynamic "http_health_check" {
    for_each = var.health_check_config.protocol == "HTTP" ? [1] : []
    content {
      port         = var.health_check_config.port
      request_path = var.health_check_config.request_path
    }
  }

  dynamic "https_health_check" {
    for_each = var.health_check_config.protocol == "HTTPS" ? [1] : []
    content {
      port         = var.health_check_config.port
      request_path = var.health_check_config.request_path
    }
  }
}

# Backend Service
resource "google_compute_backend_service" "default" {
  name                  = "${var.name}-backend-service"
  protocol              = var.backend_protocol
  port_name             = var.backend_port_name
  timeout_sec           = var.backend_timeout_sec
  enable_cdn            = var.enable_cdn
  health_checks         = [google_compute_health_check.default.id]
  load_balancing_scheme = "EXTERNAL_MANAGED"

  dynamic "backend" {
    for_each = var.backend_groups
    content {
      group           = backend.value.group
      balancing_mode  = backend.value.balancing_mode
      capacity_scaler = backend.value.capacity_scaler
      max_utilization = backend.value.max_utilization
    }
  }

  dynamic "cdn_policy" {
    for_each = var.enable_cdn ? [1] : []
    content {
      cache_mode                   = var.cdn_config.cache_mode
      client_ttl                   = var.cdn_config.client_ttl
      default_ttl                  = var.cdn_config.default_ttl
      max_ttl                      = var.cdn_config.max_ttl
      negative_caching             = var.cdn_config.negative_caching
      serve_while_stale            = var.cdn_config.serve_while_stale
      signed_url_cache_max_age_sec = var.cdn_config.signed_url_cache_max_age_sec

      dynamic "cache_key_policy" {
        for_each = var.cdn_config.cache_key_policy != null ? [1] : []
        content {
          include_host           = var.cdn_config.cache_key_policy.include_host
          include_protocol       = var.cdn_config.cache_key_policy.include_protocol
          include_query_string   = var.cdn_config.cache_key_policy.include_query_string
          query_string_whitelist = var.cdn_config.cache_key_policy.query_string_whitelist
        }
      }
    }
  }

  dynamic "log_config" {
    for_each = var.enable_logging ? [1] : []
    content {
      enable      = true
      sample_rate = var.log_sample_rate
    }
  }
}

# URL Map with path rules
resource "google_compute_url_map" "default" {
  name            = "${var.name}-url-map"
  default_service = google_compute_backend_service.default.id

  dynamic "host_rule" {
    for_each = var.host_rules
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }

  dynamic "path_matcher" {
    for_each = var.path_matchers
    content {
      name            = path_matcher.value.name
      default_service = google_compute_backend_service.default.id

      dynamic "path_rule" {
        for_each = path_matcher.value.path_rules
        content {
          paths   = path_rule.value.paths
          service = path_rule.value.service != "" ? path_rule.value.service : google_compute_backend_service.default.id
        }
      }
    }
  }
}

# Target HTTPS Proxy
resource "google_compute_target_https_proxy" "default" {
  name             = "${var.name}-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = var.use_managed_ssl ? [google_compute_managed_ssl_certificate.default[0].id] : [google_compute_ssl_certificate.default[0].id]
  ssl_policy       = var.ssl_policy_name != "" ? var.ssl_policy_name : null
}

# Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "${var.name}-forwarding-rule"
  target                = google_compute_target_https_proxy.default.id
  ip_address            = google_compute_global_address.default.address
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# HTTP to HTTPS Redirect (optional)
resource "google_compute_url_map" "http_redirect" {
  count = var.enable_http_redirect ? 1 : 0
  name  = "${var.name}-http-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "http_redirect" {
  count   = var.enable_http_redirect ? 1 : 0
  name    = "${var.name}-http-proxy"
  url_map = google_compute_url_map.http_redirect[0].id
}

resource "google_compute_global_forwarding_rule" "http_redirect" {
  count                 = var.enable_http_redirect ? 1 : 0
  name                  = "${var.name}-http-forwarding-rule"
  target                = google_compute_target_http_proxy.http_redirect[0].id
  ip_address            = google_compute_global_address.default.address
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
