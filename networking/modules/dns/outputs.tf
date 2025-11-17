output "dns_zones" {
  description = "Map of DNS zone details"
  value = merge(
    {
      for k, v in google_dns_managed_zone.private_zones : k => {
        name     = v.name
        dns_name = v.dns_name
        id       = v.id
      }
    },
    var.enable_googleapis_zone ? {
      googleapis = {
        name     = google_dns_managed_zone.googleapis[0].name
        dns_name = google_dns_managed_zone.googleapis[0].dns_name
        id       = google_dns_managed_zone.googleapis[0].id
      }
    } : {},
    var.enable_gcr_zone ? {
      gcr = {
        name     = google_dns_managed_zone.gcr[0].name
        dns_name = google_dns_managed_zone.gcr[0].dns_name
        id       = google_dns_managed_zone.gcr[0].id
      }
    } : {},
    var.enable_pkg_dev_zone ? {
      pkg_dev = {
        name     = google_dns_managed_zone.pkg_dev[0].name
        dns_name = google_dns_managed_zone.pkg_dev[0].dns_name
        id       = google_dns_managed_zone.pkg_dev[0].id
      }
    } : {}
  )
}

output "dns_zone_names" {
  description = "List of DNS zone names"
  value       = concat(
    [for zone in google_dns_managed_zone.private_zones : zone.name],
    var.enable_googleapis_zone ? [google_dns_managed_zone.googleapis[0].name] : [],
    var.enable_gcr_zone ? [google_dns_managed_zone.gcr[0].name] : [],
    var.enable_pkg_dev_zone ? [google_dns_managed_zone.pkg_dev[0].name] : []
  )
}

output "googleapis_zone_name" {
  description = "Name of googleapis zone"
  value       = var.enable_googleapis_zone ? google_dns_managed_zone.googleapis[0].name : null
}

output "gcr_zone_name" {
  description = "Name of GCR zone"
  value       = var.enable_gcr_zone ? google_dns_managed_zone.gcr[0].name : null
}

output "pkg_dev_zone_name" {
  description = "Name of pkg.dev zone"
  value       = var.enable_pkg_dev_zone ? google_dns_managed_zone.pkg_dev[0].name : null
}