# ============================================
# Subnets Module
# ============================================

resource "google_compute_subnetwork" "subnet" {
  for_each = { for idx, subnet in var.subnets : subnet.subnet_name => subnet }

  name                     = each.value.subnet_name
  project                  = var.project_id
  ip_cidr_range            = each.value.subnet_ip
  region                   = each.value.subnet_region
  network                  = var.network_id
  private_ip_google_access = each.value.subnet_private_access
  description              = each.value.description
  purpose                  = each.value.purpose
  role                     = each.value.role

  # Secondary IP ranges for GKE pods and services
  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  # VPC Flow Logs configuration
  dynamic "log_config" {
    for_each = each.value.subnet_flow_logs ? [1] : []
    content {
      aggregation_interval = try(each.value.log_config.aggregation_interval, each.value.subnet_flow_logs_interval, "INTERVAL_5_SEC")
      flow_sampling        = try(each.value.log_config.flow_sampling, each.value.subnet_flow_logs_sampling, 0.5)
      metadata             = try(each.value.log_config.metadata, each.value.subnet_flow_logs_metadata, "INCLUDE_ALL_METADATA")
      metadata_fields      = try(each.value.log_config.metadata_fields, [])
      filter_expr          = try(each.value.log_config.filter_expr, null)
    }
  }
}