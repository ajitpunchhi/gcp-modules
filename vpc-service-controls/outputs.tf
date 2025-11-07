# ==============================================================================
# OUTPUTS
# ==============================================================================

output "access_policy_id" {
  description = "ID of the Access Context Manager policy"
  value       = google_access_context_manager_access_policy.policy.id
}

output "access_policy_name" {
  description = "Full name of the Access Context Manager policy"
  value       = google_access_context_manager_access_policy.policy.name
}

output "access_level_name" {
  description = "Full name of the trusted access level"
  value       = google_access_context_manager_access_level.trusted_level.name
}

output "perimeter_name" {
  description = "Full name of the service perimeter"
  value       = google_access_context_manager_service_perimeter.storage_perimeter.name
}

output "protected_project_number" {
  description = "Project number of the protected project (Project A)"
  value       = data.google_project.protected.number
}

output "protected_project_id" {
  description = "Project ID of the protected project (Project A)"
  value       = data.google_project.protected.project_id
}

output "restricted_project_number" {
  description = "Project number of the restricted project (Project B)"
  value       = data.google_project.restricted.number
}

output "restricted_project_id" {
  description = "Project ID of the restricted project (Project B)"
  value       = data.google_project.restricted.project_id
}

output "vpc_sc_logs_bucket" {
  description = "Bucket name storing VPC SC violation logs"
  value       = google_storage_bucket.vpc_sc_logs.name
}

output "enforcement_status" {
  description = "VPC Service Controls enforcement status"
  value       = "✅ ENFORCED - Project ${local.restricted_project_id} CANNOT access storage in Project ${local.protected_project_id}"
}

output "protected_services" {
  description = "List of services protected by VPC Service Controls"
  value       = local.restricted_services
}

output "test_instructions" {
  description = "Instructions to test the VPC SC restriction"
  value       = <<-EOT
    
    ╔════════════════════════════════════════════════════════════════════╗
    ║                 VPC SC TESTING INSTRUCTIONS                        ║
    ╚════════════════════════════════════════════════════════════════════╝
    
    TEST 1: Verify Project B is BLOCKED (Expected: FAIL)
    ────────────────────────────────────────────────────────
    gcloud config set project ${local.restricted_project_id}
    gsutil ls gs://[PROJECT-A-BUCKET-NAME]/
    
    Expected Error:
    AccessDeniedException: 403 Request violates VPC Service Controls
    
    
    TEST 2: Verify Project A can access its own storage (Expected: SUCCESS)
    ────────────────────────────────────────────────────────────────────
    gcloud config set project ${local.protected_project_id}
    gsutil ls gs://[PROJECT-A-BUCKET-NAME]/
    
    Expected: Success - lists bucket contents
    
    
    TEST 3: Check VPC SC violation logs
    ────────────────────────────────────
    gsutil ls gs://${local.protected_project_id}-vpc-sc-logs/
    
    
    TEST 4: View audit logs for violations
    ───────────────────────────────────────
    gcloud logging read \
      "protoPayload.metadata.@type=\"type.googleapis.com/google.cloud.audit.VpcServiceControlAuditMetadata\"" \
      --project=${local.protected_project_id} \
      --limit=10 \
      --format=json
  EOT
}