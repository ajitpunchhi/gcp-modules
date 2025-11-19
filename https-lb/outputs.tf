# Outputs for HTTPS Load Balancer Module

output "load_balancer_ip" {
  description = "External IP address of the load balancer"
  value       = google_compute_global_address.default.address
}

output "load_balancer_ip_name" {
  description = "Name of the load balancer IP address resource"
  value       = google_compute_global_address.default.name
}

output "ssl_certificate_id" {
  description = "ID of the SSL certificate"
  value       = var.use_managed_ssl ? google_compute_managed_ssl_certificate.default[0].id : google_compute_ssl_certificate.default[0].id
}

output "ssl_certificate_name" {
  description = "Name of the SSL certificate"
  value       = var.use_managed_ssl ? google_compute_managed_ssl_certificate.default[0].name : google_compute_ssl_certificate.default[0].name
}

# output "managed_ssl_certificate_status" {
#   description = "Status of managed SSL certificate (only for managed certificates)"
#   value       = var.use_managed_ssl ? google_compute_managed_ssl_certificate.default[0].managed[0].status : "N/A - Using self-managed certificate"
# }

output "backend_service_id" {
  description = "ID of the backend service"
  value       = google_compute_backend_service.default.id
}

output "backend_service_name" {
  description = "Name of the backend service"
  value       = google_compute_backend_service.default.name
}

output "health_check_id" {
  description = "ID of the health check"
  value       = google_compute_health_check.default.id
}

output "health_check_name" {
  description = "Name of the health check"
  value       = google_compute_health_check.default.name
}

output "url_map_id" {
  description = "ID of the URL map"
  value       = google_compute_url_map.default.id
}

output "url_map_name" {
  description = "Name of the URL map"
  value       = google_compute_url_map.default.name
}

output "https_proxy_id" {
  description = "ID of the HTTPS proxy"
  value       = google_compute_target_https_proxy.default.id
}

output "https_proxy_name" {
  description = "Name of the HTTPS proxy"
  value       = google_compute_target_https_proxy.default.name
}

output "forwarding_rule_id" {
  description = "ID of the forwarding rule"
  value       = google_compute_global_forwarding_rule.default.id
}

output "forwarding_rule_name" {
  description = "Name of the forwarding rule"
  value       = google_compute_global_forwarding_rule.default.name
}

output "cdn_enabled" {
  description = "Whether CDN is enabled"
  value       = var.enable_cdn
}

output "http_redirect_enabled" {
  description = "Whether HTTP to HTTPS redirect is enabled"
  value       = var.enable_http_redirect
}

output "load_balancer_url" {
  description = "Full HTTPS URL of the load balancer"
  value       = "https://${google_compute_global_address.default.address}"
}
