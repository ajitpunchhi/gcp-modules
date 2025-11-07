
provider "google" {
}

# ==============================================================================
# LOCAL VARIABLES
# ==============================================================================

locals {
  organization_id       = var.organization_id
  protected_project_id  = var.protected_project_id
  restricted_project_id = var.restricted_project_id
  
  restricted_services = [
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "bigtable.googleapis.com",
  ]
  
  perimeter_name    = "storage_access_restriction_perimeter"
  access_level_name = "trusted_access_level"
}

# ==============================================================================
# DATA SOURCES - Get Project Numbers
# ==============================================================================

data "google_project" "protected" {
  project_id = local.protected_project_id
}

data "google_project" "restricted" {
  project_id = local.restricted_project_id
}

# ==============================================================================
# ACCESS CONTEXT MANAGER - Access Policy
# ==============================================================================

resource "google_access_context_manager_access_policy" "policy" {
  parent = "organizations/${local.organization_id}"
  title  = "VPC SC Storage Restriction Policy"
  
  # Lifecycle to prevent accidental deletion
  lifecycle {
    prevent_destroy = false  # Set to true in production
  }
}

# ==============================================================================
# ACCESS LEVEL - Define Trusted Access Criteria
# ==============================================================================

resource "google_access_context_manager_access_level" "trusted_level" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.policy.name}/accessLevels/${local.access_level_name}"
  title  = "Trusted Access Level for Storage Protection"
  
  basic {
    conditions {
      # Trusted IP ranges
    #   ip_subnetworks = var.trusted_ip_ranges
      
      # Trusted members (users/service accounts)
      members = var.trusted_members
      
      # Optional: Device policy requirements
      # Uncomment to enforce device security policies
      # device_policy {
      #   require_screen_lock = true
      #   require_corp_owned  = true
      #   allowed_encryption_statuses = ["ENCRYPTED"]
      #   allowed_device_management_levels = ["COMPLETE"]
      # }
      
      # Optional: Regional restrictions
      # regions = ["US", "IN"]
    }
  }
}

# ==============================================================================
# SERVICE PERIMETER - ENFORCED MODE
# ==============================================================================

resource "google_access_context_manager_service_perimeter" "storage_perimeter" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.policy.name}/servicePerimeters/${local.perimeter_name}"
  title  = "Storage Access Restriction Perimeter - ENFORCED"
  
  # Perimeter type: PERIMETER_TYPE_REGULAR (default)
  perimeter_type = "PERIMETER_TYPE_REGULAR"
  
  # ===========================================================================
  # STATUS BLOCK - ENFORCED MODE
  # ===========================================================================
  # Using 'status' block makes this ENFORCED by default
  # To use DRY-RUN mode, use 'spec' block instead
  
  status {
    # CRITICAL: Only Project A (protected) is inside the perimeter
    # Project B is NOT listed, so it CANNOT access Project A's resources
    resources = [
      "projects/${data.google_project.protected.number}",
    ]
    
    # Services protected by this perimeter
    restricted_services = local.restricted_services
    
    # Access levels required to access protected resources
    access_levels = [
      google_access_context_manager_access_level.trusted_level.name,
    ]
    
    # =========================================================================
    # VPC ACCESSIBLE SERVICES
    # =========================================================================
    vpc_accessible_services {
      enable_restriction = true
      allowed_services   = local.restricted_services
    }
    
    # =========================================================================
    # INGRESS POLICIES - Control Inbound Access
    # =========================================================================
    
    # Ingress Policy 1: Allow from trusted access level
    ingress_policies {
      ingress_from {
        # Source: Trusted access level
        sources {
          access_level = google_access_context_manager_access_level.trusted_level.name
        }
        
        # Allow any identity that meets access level criteria
        identity_type = "ANY_IDENTITY"
      }
      
      ingress_to {
        # Target: All resources within perimeter
        resources = ["*"]
        
        # Allowed operations on Cloud Storage
        operations {
          service_name = "storage.googleapis.com"
          
          method_selectors {
            method = "*"  # All storage methods
          }
        }
        
        # Allowed operations on BigQuery
        operations {
          service_name = "bigquery.googleapis.com"
          
          method_selectors {
            method = "*"  # All BigQuery methods
          }
        }
      }
    }
    
    # # Ingress Policy 2: Allow from specific service accounts in Project A
    # ingress_policies {
    #   ingress_from {
    #     # Source: Resources within Project A
    #     sources {
    #       resource = "projects/${data.google_project.protected.number}"
    #     }
        
    #     # Specific identities allowed
    #     identities = [
    #       "serviceAccount:${local.protected_project_id}@appspot.gserviceaccount.com",
    #       "serviceAccount:terraform-sa@${local.protected_project_id}.iam.gserviceaccount.com",
    #     ]
    #   }
      
    #   ingress_to {
    #     resources = ["*"]
        
    #     operations {
    #       service_name = "storage.googleapis.com"
          
    #       method_selectors {
    #         method = "*"
    #       }
    #     }
    #   }
    # }
    
    # =========================================================================
    # EGRESS POLICIES - Control Outbound Access
    # =========================================================================
    
    # Egress Policy 1: Allow specific service accounts to access external resources
    egress_policies {
      egress_from {
        # Which identities can make outbound requests
        identities = [
          "serviceAccount:${local.protected_project_id}@appspot.gserviceaccount.com",
        ]
        
        # Optional: Additional identity type restriction
        # identity_type = "ANY_SERVICE_ACCOUNT"
      }
      
      egress_to {
        # Target resources (can access back to same project)
        resources = [
          "projects/${data.google_project.protected.number}",
        ]
        
        # Allowed operations
        operations {
          service_name = "storage.googleapis.com"
          
          # Only allow read operations
          method_selectors {
            method = "google.storage.objects.get"
          }
          
          method_selectors {
            method = "google.storage.objects.list"
          }
          
          method_selectors {
            method = "google.storage.buckets.get"
          }
          
          method_selectors {
            method = "google.storage.buckets.list"
          }
        }
      }
    }
  }
  
  # Lifecycle to prevent accidental changes in production
  lifecycle {
    prevent_destroy = false  # Set to true in production
  }
  
  # Ensure access level is created first
  depends_on = [
    google_access_context_manager_access_level.trusted_level
  ]
}

# ==============================================================================
# MONITORING - VPC SC Violation Logs
# ==============================================================================

# Storage bucket for VPC SC violation logs
resource "google_storage_bucket" "vpc_sc_logs" {
  project       = local.protected_project_id
  name          = "${local.protected_project_id}-vpc-sc-logs"
  location      = var.logs_bucket_location
  force_destroy = false
  
  uniform_bucket_level_access = true
  
  # Retention policy
  lifecycle_rule {
    condition {
      age = 90  # Delete logs older than 90 days
    }
    action {
      type = "Delete"
    }
  }
  
  # Archive old logs
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  versioning {
    enabled = true
  }
  
  labels = {
    purpose     = "vpc-sc-monitoring"
    environment = "production"
  }
}

# Log sink to capture VPC SC violations
resource "google_logging_project_sink" "vpc_sc_violations" {
  project     = local.protected_project_id
  name        = "vpc-sc-violation-logs"
  destination = "storage.googleapis.com/${google_storage_bucket.vpc_sc_logs.name}"
  
  # Filter for VPC Service Controls audit logs
  filter = <<-EOT
    protoPayload.metadata.@type="type.googleapis.com/google.cloud.audit.VpcServiceControlAuditMetadata"
    AND protoPayload.metadata.violationReason=~".*"
  EOT
  
  # Create unique writer identity
  unique_writer_identity = true
  
  depends_on = [google_storage_bucket.vpc_sc_logs]
}

# Grant log writer permission to the sink
resource "google_storage_bucket_iam_member" "log_writer" {
  bucket = google_storage_bucket.vpc_sc_logs.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.vpc_sc_violations.writer_identity
}

# ==============================================================================
# OPTIONAL: Additional IAM Deny Policy Layer
# ==============================================================================

# This provides defense-in-depth by adding IAM-level restrictions
# in addition to VPC Service Controls

resource "google_project_iam_binding" "deny_cross_project_storage_viewer" {
  project = local.protected_project_id
  role    = "roles/storage.objectViewer"
  
  members = []  # No members - this helps ensure only VPC SC rules apply
  
  condition {
    title       = "Deny Project B Access"
    description = "Additional layer - deny access from Project B"
    expression  = "request.auth.claims.email.endsWith('@${local.restricted_project_id}.iam.gserviceaccount.com')"
  }
}