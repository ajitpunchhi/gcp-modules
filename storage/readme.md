# GCP Cloud Storage Terraform Module

[![Terraform Version](https://img.shields.io/badge/Terraform-%3E%3D1.3.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-green.svg)](https://github.com/ajitpunchhi/gcp-modules)

A production-ready Terraform module for creating and managing Google Cloud Storage (GCS) buckets with comprehensive configuration options including lifecycle policies, IAM bindings, versioning, encryption, and logging.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
  - [Basic Example](#basic-example)
  - [Advanced Example](#advanced-example)
  - [Multiple Buckets](#multiple-buckets)
- [Module Inputs](#module-inputs)
- [Module Outputs](#module-outputs)
- [Examples](#examples)
- [IAM Permissions](#iam-permissions)
- [Best Practices](#best-practices)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Features

✅ **Bucket Management**
- Create single or multiple Cloud Storage buckets
- Configurable storage classes (STANDARD, NEARLINE, COLDLINE, ARCHIVE)
- Multi-regional, regional, and dual-regional location support
- Custom naming with prefix and suffix options

✅ **Data Protection**
- Object versioning control
- Lifecycle management rules
- Retention policies and legal holds
- Soft delete policies

✅ **Security & Access Control**
- IAM role bindings (roles/storage.admin, roles/storage.objectViewer, etc.)
- Fine-grained bucket-level IAM policies
- Public access prevention
- Uniform bucket-level access control

✅ **Encryption**
- Google-managed encryption keys (default)
- Customer-managed encryption keys (CMEK)
- Customer-supplied encryption keys (CSEK) support

✅ **Monitoring & Compliance**
- Access and storage logging
- Audit log integration
- Label management for resource organization
- CORS configuration

✅ **Advanced Features**
- Website hosting configuration
- Requester pays setup
- Autoclass for automatic storage class transitions
- Custom metadata

## Prerequisites

- **Terraform**: >= 1.3.0
- **Google Provider**: >= 5.0.0
- **GCP Project**: Active project with billing enabled
- **APIs Enabled**:
  ```bash
  gcloud services enable storage-api.googleapis.com
  gcloud services enable cloudresourcemanager.googleapis.com
  ```

### Required IAM Roles

The service account or user running Terraform must have:
- `roles/storage.admin` - For bucket creation and management
- `roles/iam.serviceAccountUser` - If configuring service accounts
- `roles/resourcemanager.projectIamAdmin` - For IAM bindings

## Usage

### Basic Example

```hcl
module "gcs_bucket" {
  source = "github.com/ajitpunchhi/gcp-modules//storage"

  project_id = "my-gcp-project"
  name       = "my-application-data"
  location   = "US"
  
  labels = {
    environment = "production"
    team        = "data-engineering"
  }
}
```

### Advanced Example

```hcl
module "gcs_bucket_advanced" {
  source = "github.com/ajitpunchhi/gcp-modules//storage"

  project_id     = "my-gcp-project"
  name           = "production-data-lake"
  location       = "us-central1"
  storage_class  = "STANDARD"
  force_destroy  = false

  # Versioning
  versioning_enabled = true

  # Lifecycle rules
  lifecycle_rules = [
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
      condition = {
        age                   = 30
        matches_storage_class = ["STANDARD"]
      }
    },
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "COLDLINE"
      }
      condition = {
        age                   = 90
        matches_storage_class = ["NEARLINE"]
      }
    },
    {
      action = {
        type = "Delete"
      }
      condition = {
        age                   = 365
        with_state           = "ARCHIVED"
      }
    }
  ]

  # IAM bindings
  iam_members = [
    {
      role   = "roles/storage.objectViewer"
      member = "group:data-analysts@example.com"
    },
    {
      role   = "roles/storage.objectAdmin"
      member = "serviceAccount:data-pipeline@my-gcp-project.iam.gserviceaccount.com"
    }
  ]

  # Encryption with CMEK
  encryption = {
    default_kms_key_name = "projects/my-gcp-project/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-key"
  }

  # Logging
  logging = {
    log_bucket        = "my-logging-bucket"
    log_object_prefix = "gcs-logs/"
  }

  # CORS configuration
  cors = [
    {
      origin          = ["https://example.com"]
      method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
      response_header = ["*"]
      max_age_seconds = 3600
    }
  ]

  # Security
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  # Labels
  labels = {
    environment     = "production"
    data_classification = "confidential"
    cost_center     = "engineering"
    compliance      = "gdpr"
  }
}
```

### Multiple Buckets

```hcl
module "gcs_buckets" {
  source = "github.com/ajitpunchhi/gcp-modules//storage"

  project_id = "my-gcp-project"
  
  buckets = [
    {
      name          = "raw-data-bucket"
      location      = "us-central1"
      storage_class = "STANDARD"
      versioning_enabled = true
    },
    {
      name          = "processed-data-bucket"
      location      = "us-central1"
      storage_class = "NEARLINE"
      lifecycle_rules = [
        {
          action = {
            type = "Delete"
          }
          condition = {
            age = 90
          }
        }
      ]
    },
    {
      name          = "archive-bucket"
      location      = "us-central1"
      storage_class = "ARCHIVE"
    }
  ]

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

## Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | The GCP project ID where the bucket will be created | `string` | n/a | yes |
| `name` | The name of the bucket (must be globally unique) | `string` | n/a | yes |
| `location` | The location of the bucket (e.g., US, EU, us-central1) | `string` | `"US"` | no |
| `storage_class` | The storage class of the bucket (STANDARD, NEARLINE, COLDLINE, ARCHIVE) | `string` | `"STANDARD"` | no |
| `force_destroy` | When deleting bucket, delete all objects (use with caution) | `bool` | `false` | no |
| `versioning_enabled` | Enable versioning for objects in the bucket | `bool` | `false` | no |
| `lifecycle_rules` | List of lifecycle rules to configure bucket lifecycle management | `list(object)` | `[]` | no |
| `iam_members` | List of IAM bindings to apply to the bucket | `list(object)` | `[]` | no |
| `encryption` | Encryption configuration for the bucket | `object` | `null` | no |
| `logging` | Logging configuration for the bucket | `object` | `null` | no |
| `cors` | CORS configuration for the bucket | `list(object)` | `[]` | no |
| `website` | Website configuration for the bucket | `object` | `null` | no |
| `retention_policy` | Retention policy for the bucket | `object` | `null` | no |
| `autoclass` | Autoclass configuration for automatic storage class transitions | `object` | `null` | no |
| `public_access_prevention` | Prevents public access to the bucket (inherited or enforced) | `string` | `"enforced"` | no |
| `uniform_bucket_level_access` | Enables uniform bucket-level access | `bool` | `true` | no |
| `requester_pays` | Enables Requester Pays on the bucket | `bool` | `false` | no |
| `default_event_based_hold` | Enable default event-based hold on new objects | `bool` | `false` | no |
| `labels` | A map of key/value label pairs to assign to the bucket | `map(string)` | `{}` | no |
| `soft_delete_policy` | Soft delete policy configuration | `object` | `null` | no |
| `custom_placement_config` | Custom dual-region placement configuration | `object` | `null` | no |

### Lifecycle Rules Structure

```hcl
lifecycle_rules = [
  {
    action = {
      type          = "SetStorageClass" # or "Delete"
      storage_class = "NEARLINE"        # Required if type is SetStorageClass
    }
    condition = {
      age                        = 30                    # Days since object creation
      created_before             = "2023-01-01"          # Date in RFC 3339 format
      with_state                 = "LIVE"                # LIVE, ARCHIVED, ANY
      matches_storage_class      = ["STANDARD"]          # List of storage classes
      matches_prefix             = ["logs/"]             # Object name prefixes
      matches_suffix             = [".txt"]              # Object name suffixes
      num_newer_versions         = 3                     # Number of newer versions to keep
      custom_time_before         = "2023-01-01"          # Custom time before date
      days_since_custom_time     = 30                    # Days since custom time
      days_since_noncurrent_time = 30                    # Days since version became noncurrent
      noncurrent_time_before     = "2023-01-01"          # Noncurrent time before date
    }
  }
]
```

## Module Outputs

| Name | Description |
|------|-------------|
| `bucket_name` | The name of the created bucket |
| `bucket_url` | The base URL of the bucket, in the format `gs://<bucket-name>` |
| `bucket_self_link` | The URI of the created resource |
| `bucket_id` | The ID of the bucket (format: `projects/<project>/buckets/<name>`) |
| `bucket_location` | The location of the bucket |
| `bucket_project` | The project in which the bucket was created |
| `bucket_storage_class` | The storage class of the bucket |

## Examples

### Example 1: Static Website Hosting

```hcl
module "website_bucket" {
  source = "github.com/ajitpunchhi/gcp-modules//storage"

  project_id    = "my-gcp-project"
  name          = "my-website-bucket"
  location      = "US"
  storage_class = "STANDARD"

  website = {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  cors = [
    {
      origin          = ["*"]
      method          = ["GET", "HEAD"]
      response_header = ["*"]
      max_age_seconds = 3600
    }
  ]

  iam_members = [
    {
      role   = "roles/storage.objectViewer"
      member = "allUsers"
    }
  ]

  public_access_prevention = "inherited"  # Allow public access
}
```

### Example 2: Data Lake with Retention Policy

```hcl
module "data_lake_bucket" {
  source = "github.com/ajitpunchhi/gcp-modules//storage"

  project_id = "my-gcp-project"
  name       = "enterprise-data-lake"
  location   = "us-central1"

  versioning_enabled = true

  retention_policy = {
    retention_period = 2592000  # 30 days in seconds
    is_locked        = false    # Set to true to permanently lock the policy
  }

  lifecycle_rules = [
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "ARCHIVE"
      }
      condition = {
        age                   = 180
        matches_storage_class = ["STANDARD"]
      }
    }
  ]

  labels = {
    compliance = "sox"
    retention  = "30days"
  }
}
```

### Example 3: Backup Bucket with Encryption

```hcl
module "backup_bucket" {
  source = "github.com/ajitpunchhi/gcp-modules//storage"

  project_id    = "my-gcp-project"
  name          = "database-backups"
  location      = "us-east1"
  storage_class = "COLDLINE"

  versioning_enabled = true

  encryption = {
    default_kms_key_name = "projects/my-gcp-project/locations/us-east1/keyRings/backup-keyring/cryptoKeys/backup-key"
  }

  lifecycle_rules = [
    {
      action = {
        type = "Delete"
      }
      condition = {
        age            = 365
        num_newer_versions = 3  # Keep only 3 versions
      }
    }
  ]

  iam_members = [
    {
      role   = "roles/storage.objectCreator"
      member = "serviceAccount:backup-service@my-gcp-project.iam.gserviceaccount.com"
    }
  ]

  labels = {
    purpose     = "backup"
    retention   = "1year"
    encrypted   = "true"
  }
}
```

### Example 4: Logging Bucket

```hcl
module "logging_bucket" {
  source = "github.com/ajitpunchhi/gcp-modules//storage"

  project_id    = "my-gcp-project"
  name          = "application-logs"
  location      = "us-central1"
  storage_class = "STANDARD"

  lifecycle_rules = [
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
      condition = {
        age = 30
      }
    },
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "COLDLINE"
      }
      condition = {
        age = 90
      }
    },
    {
      action = {
        type = "Delete"
      }
      condition = {
        age = 180
      }
    }
  ]

  iam_members = [
    {
      role   = "roles/storage.objectCreator"
      member = "serviceAccount:logging-agent@my-gcp-project.iam.gserviceaccount.com"
    }
  ]

  labels = {
    purpose = "logging"
    type    = "application-logs"
  }
}
```

## IAM Permissions

### Bucket-Level Roles

Common IAM roles for Cloud Storage buckets:

| Role | Description | Permissions |
|------|-------------|-------------|
| `roles/storage.admin` | Full control of buckets and objects | All permissions |
| `roles/storage.objectAdmin` | Full control of objects | Create, list, get, delete objects |
| `roles/storage.objectCreator` | Create objects | Upload objects only |
| `roles/storage.objectViewer` | View objects | List and download objects |
| `roles/storage.legacyBucketOwner` | Legacy bucket owner | Read and write bucket metadata |
| `roles/storage.legacyBucketReader` | Legacy bucket reader | List objects in bucket |
| `roles/storage.legacyObjectOwner` | Legacy object owner | Read and write object data and metadata |
| `roles/storage.legacyObjectReader` | Legacy object reader | Read object data and metadata |

### Granting Access

```hcl
iam_members = [
  {
    role   = "roles/storage.objectViewer"
    member = "user:alice@example.com"
  },
  {
    role   = "roles/storage.objectAdmin"
    member = "serviceAccount:app@project.iam.gserviceaccount.com"
  },
  {
    role   = "roles/storage.objectCreator"
    member = "group:developers@example.com"
  }
]
```

## Best Practices

### 1. Naming Conventions

```hcl
# Use descriptive, consistent naming
name = "${var.environment}-${var.application}-${var.purpose}"

# Example: production-analytics-raw-data
```

### 2. Storage Class Selection

- **STANDARD**: Frequently accessed data (< 30 days)
- **NEARLINE**: Infrequently accessed data (30-90 days)
- **COLDLINE**: Rarely accessed data (90-365 days)
- **ARCHIVE**: Long-term archival (> 365 days)

### 3. Lifecycle Management

```hcl
# Implement automated data lifecycle
lifecycle_rules = [
  # Move to cheaper storage after 30 days
  {
    action    = { type = "SetStorageClass", storage_class = "NEARLINE" }
    condition = { age = 30 }
  },
  # Delete after 1 year
  {
    action    = { type = "Delete" }
    condition = { age = 365 }
  }
]
```

### 4. Security

```hcl
# Always enforce public access prevention
public_access_prevention    = "enforced"
uniform_bucket_level_access = true

# Use CMEK for sensitive data
encryption = {
  default_kms_key_name = var.kms_key_id
}
```

### 5. Cost Optimization

- Enable Autoclass for automatic storage class transitions
- Implement lifecycle policies to delete or archive old data
- Use nearline/coldline storage for backups
- Monitor storage usage with labels

### 6. Compliance

```hcl
# Retention policy for compliance
retention_policy = {
  retention_period = 2592000  # 30 days
  is_locked        = true     # Lock after initial testing
}

# Enable versioning for audit trails
versioning_enabled = true

# Comprehensive labeling
labels = {
  compliance         = "sox"
  data_classification = "confidential"
  retention_period   = "30days"
}
```

## Security Considerations

### 1. Access Control

- ✅ Use Uniform Bucket-Level Access (recommended)
- ✅ Enforce public access prevention
- ✅ Apply principle of least privilege
- ✅ Use service accounts for application access
- ✅ Regularly audit IAM permissions

### 2. Encryption

```hcl
# Customer-Managed Encryption Keys (CMEK)
encryption = {
  default_kms_key_name = "projects/PROJECT/locations/LOCATION/keyRings/KEYRING/cryptoKeys/KEY"
}

# Grant Cloud Storage service account access to KMS key
# gcloud kms keys add-iam-policy-binding KEY_NAME \
#   --keyring=KEYRING --location=LOCATION \
#   --member=serviceAccount:service-PROJECT_NUMBER@gs-project-accounts.iam.gserviceaccount.com \
#   --role=roles/cloudkms.cryptoKeyEncrypterDecrypter
```

### 3. Data Protection

```hcl
# Enable versioning
versioning_enabled = true

# Soft delete policy (recovery window)
soft_delete_policy = {
  retention_duration_seconds = 604800  # 7 days
}

# Object retention
retention_policy = {
  retention_period = 2592000
  is_locked        = false
}
```

### 4. Network Security

- Use VPC Service Controls to restrict data exfiltration
- Configure Private Google Access for VPC resources
- Use signed URLs for temporary access

### 5. Monitoring

```hcl
# Enable access logging
logging = {
  log_bucket        = "audit-logs-bucket"
  log_object_prefix = "storage-access-logs/"
}

# Use Cloud Monitoring alerts
# - Monitor bucket size
# - Track access patterns
# - Alert on configuration changes
```

## Troubleshooting

### Common Issues

#### Issue 1: Bucket Name Already Exists

**Error**: `Error 409: You already own this bucket. Please select another name.`

**Solution**: Bucket names are globally unique. Choose a different name or add a unique prefix/suffix.

```hcl
name = "${var.project_id}-${var.bucket_name}-${random_id.bucket_suffix.hex}"
```

#### Issue 2: Insufficient Permissions

**Error**: `Error 403: does not have storage.buckets.create access`

**Solution**: Grant required IAM roles:

```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:SERVICE_ACCOUNT_EMAIL" \
  --role="roles/storage.admin"
```

#### Issue 3: KMS Key Access Denied

**Error**: `Error 400: The Cloud Storage service account must have access to the Cloud KMS key`

**Solution**: Grant the Cloud Storage service account access to the KMS key:

```bash
gcloud kms keys add-iam-policy-binding KEY_NAME \
  --keyring=KEYRING \
  --location=LOCATION \
  --member="serviceAccount:service-PROJECT_NUMBER@gs-project-accounts.iam.gserviceaccount.com" \
  --role="roles/cloudkms.cryptoKeyEncrypterDecrypter"
```

#### Issue 4: Cannot Delete Non-Empty Bucket

**Error**: `Error 409: The bucket you tried to delete was not empty.`

**Solution**: Either delete objects first or use `force_destroy = true` (use with caution):

```hcl
force_destroy = true  # WARNING: This will delete all objects when destroying the bucket
```

#### Issue 5: Lifecycle Rule Not Working

**Solution**: Verify lifecycle rules conditions:

```bash
# Check bucket lifecycle configuration
gsutil lifecycle get gs://BUCKET_NAME

# Test lifecycle rule
gsutil lifecycle set lifecycle.json gs://BUCKET_NAME
```

### Debug Commands

```bash
# Check bucket details
gsutil ls -L -b gs://BUCKET_NAME

# Verify IAM policies
gsutil iam get gs://BUCKET_NAME

# Check bucket versioning
gsutil versioning get gs://BUCKET_NAME

# View lifecycle configuration
gsutil lifecycle get gs://BUCKET_NAME

# Check encryption configuration
gsutil encryption get gs://BUCKET_NAME
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests if applicable
5. Update documentation
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Standards

- Follow [Terraform style conventions](https://www.terraform.io/docs/language/syntax/style.html)
- Use `terraform fmt` to format code
- Run `terraform validate` before committing
- Update README.md with any new variables or outputs
- Add examples for new features

## License

This module is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for full details.

## Resources

- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Cloud Storage Pricing](https://cloud.google.com/storage/pricing)
- [Storage Classes](https://cloud.google.com/storage/docs/storage-classes)
- [Lifecycle Management](https://cloud.google.com/storage/docs/lifecycle)
- [IAM Permissions](https://cloud.google.com/storage/docs/access-control/iam-permissions)

## Support

For issues, questions, or contributions:
- **Issues**: [GitHub Issues](https://github.com/ajitpunchhi/gcp-modules/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ajitpunchhi/gcp-modules/discussions)
- **Email**: ajitpunchhi@example.com

---

**Maintained by**: [Ajit Punchhi](https://github.com/ajitpunchhi)

**Last Updated**: November 2025
