# HTTPS Load Balancer - Quick Start Guide

## 📦 Core Files Overview

You now have 4 essential Terraform files ready to deploy:

### 1. **main.tf** (13 KB)
The main configuration file containing all resources:
- Global static IP address
- SSL certificates (managed and self-managed)
- Health checks (HTTPS and TCP)
- URL maps for routing
- Target proxies (HTTPS and HTTP)
- Forwarding rules
- Backend services (default and additional)

### 2. **variables.tf** (13 KB)
All input variables with:
- Descriptions for each variable
- Default values where applicable
- Validation rules
- Type definitions
- Organized by feature (SSL, CDN, Health Checks, etc.)

### 3. **outputs.tf** (5.9 KB)
Output values for:
- Load balancer IP address and URL
- Proxy and forwarding rule IDs
- Backend service references
- Health check IDs
- Certificate information
- Configuration summary

### 4. **terraform.tfvars** (13 KB)
Example configuration with:
- Realistic example values
- Comprehensive comments
- Multiple environment examples
- Best practices
- DNS configuration information
- Usage notes

---

## 🚀 5-Minute Quick Start

### Step 1: Create Project Directory
```bash
mkdir my-https-lb
cd my-https-lb
```

### Step 2: Copy Files
```bash
cp main.tf variables.tf outputs.tf terraform.tfvars ./
```

### Step 3: Update Configuration
```bash
# Edit terraform.tfvars with your values:
# - project_id: Your GCP project
# - load_balancer_name: Desired load balancer name
# - domains: Your actual domains
# - instance groups: Your backend groups
# - ssl_certificate_ids: Reference your certs
```

### Step 4: Initialize Terraform
```bash
terraform init
```

### Step 5: Plan
```bash
terraform plan
```

### Step 6: Apply
```bash
terraform apply
```

---

## 📋 What Each File Does

### **main.tf** - Resource Definitions

Contains all Terraform resources:

```hcl
# Global IP
google_compute_global_address "lb_address"

# SSL Certificates
google_compute_managed_ssl_certificate "managed_certs"      # Auto-renewed
google_compute_ssl_certificate "self_managed_certs"         # Manual control

# Health Checks
google_compute_health_check "https_health_check"            # Primary HTTPS check
google_compute_health_check "tcp_health_check"              # Optional TCP check

# Routing
google_compute_url_map "url_map"                            # Main routing
google_compute_url_map "http_redirect"                      # HTTP→HTTPS

# SSL Policy
google_compute_ssl_policy "ssl_policy"                      # TLS/SSL configuration

# Proxies
google_compute_target_https_proxy "https_proxy"             # HTTPS with SSL
google_compute_target_http_proxy "http_proxy"               # HTTP redirect

# Forwarding Rules
google_compute_forwarding_rule "https"                      # HTTPS traffic
google_compute_forwarding_rule "http"                       # HTTP traffic

# Backend Services
google_compute_backend_service "default_backend"            # Default backend
google_compute_backend_service "additional"                 # Additional backends
```

**Features:**
- Dynamic resource creation based on variables
- Proper dependencies managed with `depends_on`
- Support for multiple backends
- CDN configuration per backend
- Health check attachment

---

### **variables.tf** - Input Definitions

Groups variables by feature:

```hcl
# Basic
project_id
region
load_balancer_name

# SSL/TLS (7 variables)
ssl_certificate_ids
managed_ssl_certificates
self_managed_ssl_certificates
enable_ssl_policy
ssl_policy_profile
min_tls_version
custom_ssl_features

# Routing (3 variables)
default_backend_service_id
host_rules
path_matchers

# Backend (9 variables)
create_default_backend
backends
additional_backends
backend_port_name
backend_timeout_sec
session_affinity
affinity_cookie_ttl_sec
connection_draining_timeout_sec
custom_request_headers

# Health Checks (6 variables)
health_check_path
health_check_port
health_check_interval_sec
health_check_timeout_sec
healthy_threshold
unhealthy_threshold
enable_tcp_health_check

# CDN (9 variables)
enable_cdn
cdn_cache_mode
cdn_default_ttl
cdn_max_ttl
cdn_client_ttl
cdn_negative_caching
cdn_negative_caching_code
cdn_include_query_string
cdn_query_string_whitelist/blacklist

# Other
enable_http_redirect
labels
```

**Validation Included:**
- Name format validation
- Numeric range validation
- Choice validation (enums)
- Custom validation rules

---

### **outputs.tf** - Output Values

Provides values for:
```hcl
# Connection Information
load_balancer_ip          # IP address to use
load_balancer_url         # HTTPS URL
dns_configuration_info    # DNS setup instructions

# Resource References
https_proxy_id            # For reference in other configs
default_backend_service_id
additional_backend_services
url_map_id

# Health Information
https_health_check_id
tcp_health_check_id

# Certificate References
managed_ssl_certificates
self_managed_ssl_certificates

# Security
ssl_policy_id

# Summary
load_balancer_info        # Complete configuration summary
```

**Usage:**
```bash
# Get the IP address after deployment
terraform output load_balancer_ip

# Get the URL
terraform output load_balancer_url

# Reference in other modules
module.load_balancer.default_backend_service_id
```

---

### **terraform.tfvars** - Configuration Example

Pre-filled example with:
- Real-world values
- Multiple backends (API, static, media)
- Host and path-based routing
- Different CDN policies per backend
- Extensive comments
- Best practices

**Key Sections:**

1. **Basic Configuration**
   - project_id, region, load_balancer_name

2. **SSL Certificates**
   - Google-managed (commented example)
   - Self-managed (commented example)

3. **SSL Policy**
   - MODERN profile recommended
   - TLS 1.2 minimum

4. **Health Checks**
   - Path, port, intervals, thresholds

5. **Backends**
   - Multiple instance groups
   - Per-backend configuration

6. **Routing**
   - Host rules (domain-based)
   - Path matchers (URL-based)
   - Additional backend services

7. **CDN**
   - Enabled by default
   - Per-backend CDN policies
   - Configurable TTLs

---

## 🔧 Customization Guide

### Change Load Balancer Name
```hcl
# In terraform.tfvars
load_balancer_name = "my-new-lb-name"
```

### Add a Domain
```hcl
# In terraform.tfvars
managed_ssl_certificates = [
  {
    name   = "my-cert"
    domains = ["example.com", "new-domain.com"]  # Add here
  }
]
```

### Use Different SSL Policy
```hcl
# COMPATIBLE (oldest clients)
ssl_policy_profile = "COMPATIBLE"

# MODERN (recommended)
ssl_policy_profile = "MODERN"

# RESTRICTED (maximum security)
ssl_policy_profile = "RESTRICTED"
```

### Disable CDN
```hcl
enable_cdn = false
```

### Add Custom Cache Headers
```hcl
custom_request_headers = [
  "X-Client-Region:us-central1",
  "X-Service:my-app"
]
```

### Enable TCP Health Check
```hcl
enable_tcp_health_check = true
```

---

## 📊 Common Deployments

### 1. Simple Single Backend
```hcl
# Minimal configuration
project_id          = "my-project"
load_balancer_name  = "simple-lb"
create_default_backend = true
backends = [{
  group           = "projects/my-project/zones/us-central1-a/instanceGroups/my-ig"
  balancing_mode  = "RATE"
  capacity_scaler = 1.0
  max_rate        = 100
  ...
}]
ssl_certificate_ids = ["projects/my-project/global/sslCertificates/my-cert"]
```

### 2. Multiple Backends (API + Static)
```hcl
# Use additional_backends for API and static content
additional_backends = [
  {
    name         = "api-backend"
    enable_cdn   = false      # APIs shouldn't be cached
    ...
  },
  {
    name         = "static-backend"
    enable_cdn   = true       # Cache static content
    cdn_cache_mode = "CACHE_ALL_STATIC"
    cdn_max_ttl  = 604800     # 7 days
    ...
  }
]
```

### 3. Production Setup
```hcl
# Maximum security and performance
enable_ssl_policy      = true
ssl_policy_profile     = "RESTRICTED"
enable_cdn             = true
cdn_cache_mode         = "USE_ORIGIN_HEADERS"
enable_http_redirect   = true
enable_tcp_health_check = true
```

---

## ✅ Pre-Deployment Checklist

Before running `terraform apply`:

- [ ] GCP project created and billing enabled
- [ ] Update project_id in terraform.tfvars
- [ ] Domains registered for SSL certificates
- [ ] Backend instance groups created in GCP
- [ ] Update instance group paths in terraform.tfvars
- [ ] Health check endpoint implemented on backends
- [ ] Firewall rules allow health check traffic (35.191.0.0/16, 130.211.0.0/22)
- [ ] All required variables filled in terraform.tfvars
- [ ] Review terraform plan output before applying

---

## 🚀 Deployment Steps

### 1. Prepare
```bash
# Create directory
mkdir my-lb-project
cd my-lb-project

# Copy files
cp main.tf variables.tf outputs.tf terraform.tfvars ./
```

### 2. Configure
```bash
# Edit terraform.tfvars with your values
vim terraform.tfvars
```

### 3. Validate
```bash
# Validate syntax
terraform validate

# Format check
terraform fmt -check
```

### 4. Plan
```bash
# Review what will be created
terraform plan -out=tfplan
```

### 5. Apply
```bash
# Create resources
terraform apply tfplan

# Save output
terraform output > outputs.txt
```

### 6. Configure DNS
```bash
# Get the IP address
LB_IP=$(terraform output -raw load_balancer_ip)
echo "Update DNS to point to: $LB_IP"

# For Google Cloud DNS example:
gcloud dns record-sets create example.com \
  --rrdatas=$LB_IP \
  --ttl=300 \
  --type=A \
  --zone=my-zone
```

### 7. Verify
```bash
# Check that resources were created
gcloud compute forwarding-rules list
gcloud compute backend-services list

# Wait for certificate provisioning (can take 5-10 minutes)
gcloud compute managed-ssl-certificates describe my-cert

# Test connectivity
curl -I https://example.com
```

---

## 🔍 Accessing Outputs

After `terraform apply`, access deployment info:

```bash
# Get load balancer IP
terraform output load_balancer_ip

# Get HTTPS URL
terraform output load_balancer_url

# Get backend service ID
terraform output default_backend_service_id

# Get health check ID
terraform output https_health_check_id

# Get all outputs
terraform output

# Get output as JSON
terraform output -json
```

---

## 🐛 Troubleshooting

### Issue: Validation Error
```
Error: load_balancer_name must be lowercase alphanumeric with hyphens
```
**Solution**: Use only lowercase letters, numbers, and hyphens

### Issue: Certificate Not Provisioning
**Solution**: 
1. Ensure DNS is updated to point to LB IP
2. Wait 5-10 minutes for provisioning
3. Check: `gcloud compute managed-ssl-certificates describe <name>`

### Issue: Backends Unhealthy
**Solution**:
1. Verify health check endpoint responds on specified port
2. Check firewall rules allow health check traffic
3. Verify application is listening on correct port
4. Test: `curl https://backend-ip/healthz`

### Issue: SSL Certificate Not Found
**Solution**: Ensure `ssl_certificate_ids` references valid certificate IDs from your project

---

## 📚 Files at a Glance

| File | Lines | Purpose |
|------|-------|---------|
| main.tf | 400+ | All resource definitions |
| variables.tf | 400+ | Input variables and validation |
| outputs.tf | 150+ | Output values for reference |
| terraform.tfvars | 400+ | Example configuration with comments |

**Total**: 1,350+ lines of production-ready code

---

## 🎯 Next Steps

1. **Update terraform.tfvars** with your values
2. **Run terraform plan** to review changes
3. **Run terraform apply** to deploy
4. **Update DNS** to point to load balancer IP
5. **Wait for certificates** to provision (5-10 minutes)
6. **Test HTTPS** connectivity
7. **Monitor** health checks and metrics

---

## 💡 Pro Tips

1. **Use Google-managed certificates** - No renewal hassle
2. **Enable CDN** - Improves performance and reduces costs
3. **Use appropriate health check interval** - 10 seconds is standard
4. **Implement health check endpoint** - Must respond to status checks
5. **Use MODERN SSL profile** - For best security
6. **Monitor cache hit rate** - Optimize CDN configuration
7. **Set up billing alerts** - Monitor load balancer costs

---

## 🔗 Resources

- [Google Cloud Load Balancing Documentation](https://cloud.google.com/load-balancing/docs)
- [Cloud CDN Documentation](https://cloud.google.com/cdn/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest)
- [GCP Security Best Practices](https://cloud.google.com/docs/security/best-practices)

---

**Ready to deploy? Edit terraform.tfvars and run `terraform init`!** 🚀
