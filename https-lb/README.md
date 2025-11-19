# HTTPS Load Balancer Terraform Module

A comprehensive Terraform module for creating a Google Cloud HTTPS Load Balancer with SSL termination, URL mapping, backend service configuration, health checks, and CDN integration.

## Features

- ✅ **SSL Termination**: Support for both Google-managed and self-managed SSL certificates
- ✅ **URL Mapping**: Flexible host and path-based routing
- ✅ **Backend Services**: Configurable backend service with multiple instance groups
- ✅ **Health Checks**: Customizable HTTP/HTTPS health checks
- ✅ **CDN Integration**: Built-in Cloud CDN support with configurable caching policies
- ✅ **HTTP to HTTPS Redirect**: Optional automatic redirect from HTTP to HTTPS
- ✅ **Access Logging**: Optional request logging with configurable sample rates
- ✅ **SSL Policies**: Support for custom SSL policies

## Architecture

```
Internet → Global Forwarding Rule (443) → HTTPS Proxy → URL Map → Backend Service → Instance Groups
                                             ↓
                                        SSL Certificate
                                             ↓
                                        Health Check
                                             ↓
                                        CDN (optional)
```

## Prerequisites

- Terraform >= 1.0
- Google Cloud Project
- Service account with appropriate permissions
- Backend instance groups already created

## Usage

### Basic Usage with Managed SSL

```hcl
module "https_lb" {
  source = "./https-lb-module"

  name       = "my-load-balancer"
  project_id = "my-gcp-project"

  # Use Google-managed SSL
  use_managed_ssl     = true
  managed_ssl_domains = ["example.com", "www.example.com"]

  # Backend configuration
  backend_groups = [
    {
      group           = "projects/my-project/zones/us-central1-a/instanceGroups/my-ig"
      balancing_mode  = "UTILIZATION"
      capacity_scaler = 1.0
      max_utilization = 0.8
    }
  ]

  # Enable CDN
  enable_cdn = true
}
```

### Advanced Usage with Self-Managed SSL and URL Mapping

```hcl
module "https_lb" {
  source = "./https-lb-module"

  name       = "advanced-load-balancer"
  project_id = "my-gcp-project"

  # Use self-managed SSL
  use_managed_ssl = false
  ssl_certificate = file("path/to/certificate.crt")
  ssl_private_key = file("path/to/private.key")

  # Backend configuration
  backend_protocol    = "HTTP"
  backend_port_name   = "http"
  backend_timeout_sec = 30

  backend_groups = [
    {
      group           = "projects/my-project/zones/us-central1-a/instanceGroups/my-ig"
      balancing_mode  = "UTILIZATION"
      capacity_scaler = 1.0
      max_utilization = 0.8
    }
  ]

  # Custom health check
  health_check_config = {
    protocol            = "HTTP"
    port                = 8080
    request_path        = "/healthz"
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  # URL mapping for path-based routing
  host_rules = [
    {
      hosts        = ["example.com"]
      path_matcher = "main-paths"
    }
  ]

  path_matchers = [
    {
      name = "main-paths"
      path_rules = [
        {
          paths   = ["/api/*"]
          service = google_compute_backend_service.api_backend.id
        },
        {
          paths   = ["/static/*"]
          service = google_compute_backend_service.static_backend.id
        }
      ]
    }
  ]

  # CDN configuration
  enable_cdn = true
  cdn_config = {
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
      include_query_string   = false
      query_string_whitelist = []
    }
  }

  # Enable features
  enable_http_redirect = true
  enable_logging       = true
  log_sample_rate      = 0.5
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name prefix for all resources | string | - | yes |
| project_id | GCP Project ID | string | - | yes |
| use_managed_ssl | Use Google-managed SSL certificate | bool | true | no |
| managed_ssl_domains | Domains for managed SSL | list(string) | [] | no |
| ssl_certificate | SSL certificate content | string | "" | no |
| ssl_private_key | SSL private key content | string | "" | no |
| backend_protocol | Backend protocol | string | "HTTP" | no |
| backend_groups | Backend instance groups | list(object) | [] | no |
| health_check_config | Health check configuration | object | see variables.tf | no |
| enable_cdn | Enable Cloud CDN | bool | false | no |
| cdn_config | CDN configuration | object | see variables.tf | no |
| enable_http_redirect | Enable HTTP to HTTPS redirect | bool | true | no |

See [variables.tf](variables.tf) for complete list of inputs.

## Outputs

| Name | Description |
|------|-------------|
| load_balancer_ip | External IP address of the load balancer |
| load_balancer_url | Full HTTPS URL of the load balancer |
| ssl_certificate_id | ID of the SSL certificate |
| backend_service_id | ID of the backend service |
| health_check_id | ID of the health check |

See [outputs.tf](outputs.tf) for complete list of outputs.

## Deployment Steps

1. **Prepare your backend instance groups**:
   ```bash
   # Ensure your instance groups are created with named ports
   gcloud compute instance-groups set-named-ports my-ig \
     --named-ports http:80 \
     --zone us-central1-a
   ```

2. **Copy and customize terraform.tfvars**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

6. **Get the load balancer IP**:
   ```bash
   terraform output load_balancer_ip
   ```

7. **Update DNS records** to point to the load balancer IP

8. **Wait for SSL certificate provisioning** (for managed certificates):
   - Managed SSL certificates can take 10-20 minutes to provision
   - Check status: `terraform output managed_ssl_certificate_status`

## Important Notes

### Managed SSL Certificates
- Domains must be pointed to the load balancer IP before certificate provisioning
- Certificate provisioning can take 10-20 minutes
- Requires public DNS records

### Self-Managed SSL Certificates
- Must provide valid certificate and private key
- Certificates must be in PEM format
- You're responsible for certificate renewal

### CDN Configuration
- CDN is only available with HTTP(S) load balancers
- Caching works best with static content
- Configure cache keys appropriately for your use case

### Health Checks
- Ensure your backend instances respond to health check requests
- Unhealthy backends are automatically removed from the pool
- Configure thresholds based on your application needs

## Examples

See the [examples](examples/) directory for complete usage examples:
- Basic HTTPS load balancer
- Load balancer with CDN
- Multi-region load balancer
- Path-based routing

## Contributing

Contributions are welcome! Please submit pull requests or issues.

## License

MIT License
