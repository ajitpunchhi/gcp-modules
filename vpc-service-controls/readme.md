# GCP VPC Service Controls Module

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

This Terraform module provides a comprehensive solution for deploying and managing Google Cloud Platform (GCP) VPC Service Controls and Access Context Manager policies. VPC Service Controls is an enterprise-grade security solution that helps organizations mitigate data exfiltration risks by creating security perimeters around sensitive cloud resources.

## Overview

VPC Service Controls (VPC-SC) is an organization-level security control in Google Cloud that enables enterprises to implement a zero-trust security model. This module abstracts the complexity of VPC Service Controls configuration and provides opinionated defaults for best practices while maintaining flexibility for custom requirements.

### Key Features

- **Access Policy Management**: Create and manage organization-level access policies
- **Service Perimeters**: Define security perimeters around GCP projects and services
- **Access Levels**: Configure granular access controls based on identity and context
- **Ingress/Egress Rules**: Control data flow in and out of security perimeters
- **Dry-Run Mode**: Test policies before enforcement
- **Multi-Service Support**: Protect multiple GCP services (Cloud Storage, BigQuery, Pub/Sub, etc.)
- **IAM Integration**: Seamless integration with Cloud IAM roles and service accounts

## Prerequisites

Before using this module, ensure you have the following:

- **GCP Organization**: VPC Service Controls operates at the organization level
- **Terraform** >= 1.0
- **Google Provider** >= 4.0
- **Required GCP APIs Enabled**:
  - `accesscontextmanager.googleapis.com`
  - `cloudresourcemanager.googleapis.com`
  - `serviceusage.googleapis.com`

- **Required IAM Roles**:
  - `roles/accesscontextmanager.policyAdmin` (at organization level)
  - `roles/resourcemanager.organizationAdmin` (or equivalent)

### Enable Required APIs

```bash
gcloud services enable \
  accesscontextmanager.googleapis.com \
  cloudresourcemanager.googleapis.com \
  serviceusage.googleapis.com \
  --project=YOUR_PROJECT_ID
```

### Grant Required Permissions

```bash
gcloud organizations add-iam-policy-binding ORGANIZATION_ID \
  --member="serviceAccount:terraform@project-id.iam.gserviceaccount.com" \
  --role="roles/accesscontextmanager.policyAdmin"

gcloud organizations add-iam-policy-binding ORGANIZATION_ID \
  --member="serviceAccount:terraform@project-id.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.organizationAdmin"
```

## Usage

### Basic Example

```hcl
module "access_policy" {
  source = "./vpc-service-controls"

  parent_id   = "organizations/1234567890"
  policy_name = "my-access-policy"
  
  tags = {
    environment = "production"
    team        = "security"
  }
}
```

### Complete Example with Service Perimeter

```hcl
module "access_policy" {
  source = "./vpc-service-controls"

  parent_id   = "organizations/1234567890"
  policy_name = "enterprise-policy"
}

module "access_level_employees" {
  source = "./vpc-service-controls//modules/access_level"

  policy           = module.access_policy.policy_id
  access_level_name = "employees_on_corp_network"
  
  ip_subnetworks = ["203.0.113.0/24"]
  required_access_level = false
}

module "regular_service_perimeter" {
  source = "./vpc-service-controls//modules/regular_service_perimeter"

  policy_id              = module.access_policy.policy_id
  perimeter_name         = "sensitive-data-perimeter"
  description            = "Perimeter protecting sensitive data projects"
  
  protected_project_ids = [
    "project-sensitive-data-1",
    "project-sensitive-data-2"
  ]
  
  restricted_services = [
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "pubsub.googleapis.com"
  ]
  
  access_levels = [module.access_level_employees.access_level_name]
  
  egress_policies = [{
    egress_from = {
      identity_type = "ANY_USER_ACCOUNT"
    }
    egress_to = {
      resources = ["*"]
      operations = [{
        service_name = "storage.googleapis.com"
        method_selectors = ["*"]
      }]
    }
  }]

  ingress_policies = [{
    ingress_from = {
      sources = [{
        access_level = module.access_level_employees.access_level_name
      }]
      identities = ["serviceAccount:app@project.iam.gserviceaccount.com"]
    }
    ingress_to = {
      resources = ["*"]
      operations = [{
        service_name = "storage.googleapis.com"
        method_selectors = ["*"]
      }]
    }
  }]

  enforcement_mode = "DRY_RUN"  # Set to "ENFORCED" when ready
}
```

### Dry-Run Mode

Start with dry-run mode to test policies without blocking access:

```hcl
module "service_perimeter" {
  source = "./vpc-service-controls//modules/regular_service_perimeter"

  enforcement_mode = "DRY_RUN"
  # ... other configuration
}
```

Once you've validated the policy, change to enforced mode:

```hcl
enforcement_mode = "ENFORCED"
```


## Input Variables

### Main Module Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|:--------:|
| `parent_id` | The parent of this AccessPolicy in the form organizations/{organization_id}. | `string` | - | Yes |
| `policy_name` | Human readable title. Does not affect behavior. | `string` | - | Yes |
| `scopes` | Scopes of the AccessPolicy. The only supported value is FOLDER. | `list(string)` | `[]` | No |
| `tags` | A map of tags to add to all resources. | `map(string)` | `{}` | No |

## Outputs

| Output | Description |
|--------|-------------|
| `policy_id` | The ID of the created Access Policy |
| `policy_name` | The name of the created Access Policy |
| `perimeter_names` | List of service perimeter names created |
| `access_level_names` | List of access level names created |

## Supported GCP Services

This module supports VPC Service Controls for the following GCP services:

- Cloud Storage (`storage.googleapis.com`)
- BigQuery (`bigquery.googleapis.com`)
- Cloud Pub/Sub (`pubsub.googleapis.com`)
- Cloud Datastore (`datastore.googleapis.com`)
- Cloud Spanner (`spanner.googleapis.com`)
- Cloud SQL (`sql.googleapis.com`)
- AI Platform / Vertex AI (`aiplatform.googleapis.com`)
- And many more...

For a complete list, refer to [GCP VPC Service Controls Supported Products](https://cloud.google.com/vpc-service-controls/docs/supported-products).

## Best Practices

### 1. Start with Dry-Run Mode
Always test policies in dry-run mode first to understand their impact:

```hcl
enforcement_mode = "DRY_RUN"
```

### 2. Granular Access Levels
Create specific access levels for different user groups and scenarios:

```hcl
module "access_level_admin" {
  source = "./vpc-service-controls//modules/access_level"
  policy = module.access_policy.policy_id
  access_level_name = "admin_access"
  members = ["user:admin@company.com"]
}

module "access_level_developer" {
  source = "./vpc-service-controls//modules/access_level"
  policy = module.access_policy.policy_id
  access_level_name = "developer_access"
  members = ["user:dev@company.com"]
}
```

### 3. Least Privilege
Restrict services and resources to only what's necessary:

```hcl
restricted_services = [
  "storage.googleapis.com",
  "bigquery.googleapis.com"
]
```

### 4. Monitor and Audit
Enable Cloud Audit Logs to track VPC Service Controls activity:

```bash
gcloud logging sinks create vpc-sc-audit \
  logging.googleapis.com/projects/YOUR_PROJECT/logs/vpc-service-controls \
  --log-filter='resource.type="api" AND protoPayload.status.code=7'
```

### 5. Use Terraform State Locking
Prevent concurrent modifications:

```hcl
terraform {
  backend "gcs" {
    bucket  = "terraform-state-bucket"
    prefix  = "vpc-service-controls"
    encryption_key = "your-encryption-key"
  }
}
```

## Common Issues and Troubleshooting

### Issue: Access Denied When Creating Policies
**Solution**: Verify that your service account has the `roles/accesscontextmanager.policyAdmin` role at the organization level.

### Issue: Services Stop Working After Enabling Perimeter
**Solution**: Ensure you've configured appropriate ingress and egress policies. Start in dry-run mode to test before enforcement.

### Issue: Terraform Changes Show on Every Plan
**Solution**: This may indicate a race condition. Use `terraform refresh` to synchronize state, or add `lifecycle { ignore_changes = [...] }` if needed.

## Maintenance

### Updating Policies
Update the module configuration and run:

```bash
terraform plan
terraform apply
```

### Removing Policies
To remove VPC Service Controls policies, set the enforcement mode to dry-run first, then destroy the resources:

```bash
terraform destroy
```

## Security Considerations

- **Organization Level**: VPC Service Controls operate at the organization level. Plan accordingly.
- **Data Exfiltration**: While VPC Service Controls mitigates data exfiltration, it should be part of a defense-in-depth strategy.
- **Regular Audits**: Regularly review and audit access policies and perimeters.
- **Service Account Management**: Carefully manage service accounts that operate within perimeters.
