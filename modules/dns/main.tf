# ============================================
# Private DNS Module
# ============================================

# Custom private DNS zones
resource "google_dns_managed_zone" "private_zones" {
  for_each = { for zone in var.private_zones : zone.name => zone }

  name        = each.value.name
  project     = var.project_id
  dns_name    = each.value.dns_name
  description = each.value.description
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.network_id
    }
  }
}

# DNS records for custom zones
resource "google_dns_record_set" "records" {
  for_each = {
    for record in flatten([
      for zone_key, zone in var.private_zones : [
        for record in zone.records : {
          zone_name = zone.name
          name      = record.name
          type      = record.type
          ttl       = record.ttl
          rrdatas   = record.rrdatas
          key       = "${zone.name}-${record.name}-${record.type}"
        }
      ]
    ]) : record.key => record
  }

  project      = var.project_id
  managed_zone = google_dns_managed_zone.private_zones[each.value.zone_name].name
  name         = "${each.value.name}.${google_dns_managed_zone.private_zones[each.value.zone_name].dns_name}"
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas
}

# Private DNS zone for googleapis.com
resource "google_dns_managed_zone" "googleapis" {
  count = var.enable_googleapis_zone ? 1 : 0

  name        = "${var.network_name}-googleapis"
  project     = var.project_id
  dns_name    = "googleapis.com."
  description = "Private DNS zone for Google APIs"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.network_id
    }
  }
}

resource "google_dns_record_set" "googleapis_cname" {
  count = var.enable_googleapis_zone ? 1 : 0

  project      = var.project_id
  managed_zone = google_dns_managed_zone.googleapis[0].name
  name         = "*.googleapis.com."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["restricted.googleapis.com."]
}

resource "google_dns_record_set" "googleapis_a" {
  count = var.enable_googleapis_zone ? 1 : 0

  project      = var.project_id
  managed_zone = google_dns_managed_zone.googleapis[0].name
  name         = "restricted.googleapis.com."
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
}

# Private DNS zone for gcr.io
resource "google_dns_managed_zone" "gcr" {
  count = var.enable_gcr_zone ? 1 : 0

  name        = "${var.network_name}-gcr"
  project     = var.project_id
  dns_name    = "gcr.io."
  description = "Private DNS zone for Google Container Registry"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.network_id
    }
  }
}

resource "google_dns_record_set" "gcr_cname" {
  count = var.enable_gcr_zone ? 1 : 0

  project      = var.project_id
  managed_zone = google_dns_managed_zone.gcr[0].name
  name         = "*.gcr.io."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["gcr.io."]
}

resource "google_dns_record_set" "gcr_a" {
  count = var.enable_gcr_zone ? 1 : 0

  project      = var.project_id
  managed_zone = google_dns_managed_zone.gcr[0].name
  name         = "gcr.io."
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
}

# Private DNS zone for pkg.dev (Artifact Registry)
resource "google_dns_managed_zone" "pkg_dev" {
  count = var.enable_pkg_dev_zone ? 1 : 0

  name        = "${var.network_name}-pkg-dev"
  project     = var.project_id
  dns_name    = "pkg.dev."
  description = "Private DNS zone for Artifact Registry"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.network_id
    }
  }
}

resource "google_dns_record_set" "pkg_dev_cname" {
  count = var.enable_pkg_dev_zone ? 1 : 0

  project      = var.project_id
  managed_zone = google_dns_managed_zone.pkg_dev[0].name
  name         = "*.pkg.dev."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["pkg.dev."]
}

resource "google_dns_record_set" "pkg_dev_a" {
  count = var.enable_pkg_dev_zone ? 1 : 0

  project      = var.project_id
  managed_zone = google_dns_managed_zone.pkg_dev[0].name
  name         = "pkg.dev."
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
}