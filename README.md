# GCP Networking Modules

A collection of reusable Terraform modules for managing Google Cloud Platform (GCP) networking infrastructure. These modules provide a standardized, maintainable approach to deploying and managing VPC networks, subnets, firewall rules, Cloud NAT, VPN connections, and other networking components in GCP.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Module Structure](#module-structure)
- [Usage](#usage)
- [Modules](#modules)
  - [VPC Network](#vpc-network)
  - [Subnets](#subnets)
  - [Firewall Rules](#firewall-rules)
  - [Cloud NAT](#cloud-nat)
  - [Cloud Router](#cloud-router)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
- [License](#license)

## Overview

This repository contains modular Terraform configurations for deploying GCP networking resources following Google Cloud best practices. Each module is designed to be:

- **Reusable**: Can be used across multiple projects and environments
- **Composable**: Modules can be combined to create complex networking architectures
- **Secure**: Implements security best practices by default
- **Maintainable**: Clean code structure with clear documentation

## Features

- ✅ VPC network creation with custom or auto mode
- ✅ Subnet management with secondary IP ranges
- ✅ Firewall rule configuration (ingress/egress)
- ✅ Cloud NAT for outbound internet connectivity
- ✅ Private Service Connection
- ✅ Network tags and labels support

## Prerequisites

Before using these modules, ensure you have:

- **Terraform**: Version 1.3.0 or higher
- **Google Cloud SDK**: Latest version installed and configured
- **GCP Project**: An active GCP project with billing enabled
- **IAM Permissions**: Appropriate permissions to create networking resources
  - `compute.networks.*`
  - `compute.subnetworks.*`
  - `compute.firewalls.*`
  - `compute.routers.*`
  - `compute.vpnGateways.*`

### Required APIs

Enable the following APIs in your GCP project:

```bash
gcloud services enable compute.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable dns.googleapis.com
```

## Module Structure

```
├── modules/
│ ├── vpc/ # Creates a custom-mode VPC
│ ├── subnets/ # Subnet creation with secondary IP ranges
│ ├── cloud_nat/ # Cloud Router + Cloud NAT configuration
│ ├── psc/ # Private Service Connect / VPC peering
│ └── private_dns/ # Private DNS zone
├── main.tf # Example root module wiring everything together
├── variables.tf # Root inputs
├── outputs.tf # Root outputs
└── terraform.tfvars # Example variable values
└── README.md
```

## Usage

### Quick Start

```hcl
# Basic VPC Network
module "vpc" {
  source = "./modules/vpc"

  project_id   = "my-gcp-project"
  network_name = "my-vpc-network"
  routing_mode = "GLOBAL"
  
  auto_create_subnetworks = false
  delete_default_routes   = true
}

# Create Subnets
module "subnets" {
  source = "./modules/subnets"

  project_id   = "my-gcp-project"
  network_name = module.vpc.network_name

  subnets = [
    {
      subnet_name           = "subnet-01"
      subnet_ip             = "10.0.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = true
      description           = "Production subnet"
    },
    {
      subnet_name           = "subnet-02"
      subnet_ip             = "10.0.2.0/24"
      subnet_region         = "us-east1"
      subnet_private_access = true
      description           = "Development subnet"
    }
  ]
}

# Firewall Rules
module "firewall" {
  source = "./modules/firewall"

  project_id   = "my-gcp-project"
  network_name = module.vpc.network_name

  rules = [
    {
      name        = "allow-ssh"
      description = "Allow SSH from IAP"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["35.235.240.0/20"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    }
  ]
}

# Cloud NAT
module "cloud_nat" {
  source = "./modules/cloud-nat"

  project_id = "my-gcp-project"
  region     = "us-central1"
  router     = module.cloud_router.router.name
  name       = "nat-config"
}
```

## Modules

### VPC Network

Creates a VPC network with configurable routing mode and subnet creation options.

**Location**: `modules/vpc/`

**Key Features**:
- Custom or auto-mode VPC creation
- Global or regional routing
- MTU configuration
- Delete default routes option

**Example**:
```hcl
module "vpc" {
  source = "./modules/vpc"

  project_id              = var.project_id
  network_name            = "production-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  description             = "Production VPC Network"
  
  delete_default_routes = true
  mtu                  = 1460
}
```

### Subnets

Manages VPC subnets with support for secondary IP ranges and private Google access.

**Location**: `modules/subnets/`

**Key Features**:
- Primary and secondary IP ranges
- Private Google Access
- Flow logs configuration
- Regional subnet deployment

**Example**:
```hcl
module "subnets" {
  source = "./modules/subnets"

  project_id   = var.project_id
  network_name = module.vpc.network_name

  subnets = [
    {
      subnet_name   = "prod-subnet-us-central1"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = "us-central1"
      
      subnet_private_access = true
      subnet_flow_logs      = true
      
      secondary_ranges = [
        {
          range_name    = "pods"
          ip_cidr_range = "10.20.0.0/16"
        },
        {
          range_name    = "services"
          ip_cidr_range = "10.30.0.0/16"
        }
      ]
    }
  ]
}
```

### Firewall Rules

Creates and manages firewall rules for ingress and egress traffic control.

**Location**: `modules/firewall/`

**Key Features**:
- Ingress and egress rules
- Protocol and port specifications
- Source/destination tags and ranges
- Priority management

**Example**:
```hcl
module "firewall" {
  source = "./modules/firewall"

  project_id   = var.project_id
  network_name = module.vpc.network_name

  rules = [
    {
      name                    = "allow-internal"
      description             = "Allow internal communication"
      direction               = "INGRESS"
      priority                = 65534
      ranges                  = ["10.0.0.0/8"]
      source_tags             = []
      target_tags             = []
      allow = [
        {
          protocol = "tcp"
          ports    = ["0-65535"]
        },
        {
          protocol = "udp"
          ports    = ["0-65535"]
        },
        {
          protocol = "icmp"
          ports    = []
        }
      ]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }
  ]
}
```

### Cloud NAT

Configures Cloud NAT for outbound internet connectivity from private instances.

**Location**: `modules/cloud-nat/`

**Key Features**:
- Manual or automatic IP allocation
- NAT IP address reservation
- Logging configuration
- Min/max ports per VM

**Example**:
```hcl
module "cloud_nat" {
  source = "./modules/cloud-nat"

  project_id = var.project_id
  region     = "us-central1"
  router     = module.cloud_router.router.name
  
  name = "nat-us-central1"
  
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  min_ports_per_vm = 64
  max_ports_per_vm = 65536
  
  log_config = {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
```

## Best Practices

### Network Design

1. **Use Custom Mode VPCs**: Avoid auto-mode VPCs in production for better control
2. **Plan IP Address Space**: Use RFC 1918 private IP ranges and avoid overlaps
3. **Regional Subnets**: Leverage regional subnets for better resource distribution
4. **Secondary IP Ranges**: Use for GKE pods and services

### Security

1. **Principle of Least Privilege**: Create specific firewall rules instead of broad allow rules
2. **Private Google Access**: Enable for accessing Google APIs without external IPs
3. **VPC Flow Logs**: Enable for network monitoring and troubleshooting
4. **Network Tags**: Use for granular firewall rule application

### High Availability

1. **Multi-Region Deployment**: Deploy resources across multiple regions
2. **HA VPN**: Use HA VPN for 99.99% SLA
3. **Cloud NAT**: Configure with multiple NAT IPs for redundancy
4. **Health Checks**: Implement for load balancers and VPN tunnels

### Operational Excellence

1. **Naming Conventions**: Use consistent naming across resources
2. **Tagging Strategy**: Implement comprehensive labeling for cost tracking
3. **Documentation**: Keep network diagrams and documentation updated
4. **Monitoring**: Set up Cloud Monitoring and logging for all network resources

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Terraform best practices and style guide
- Include tests for new modules
- Update documentation for any changes
- Ensure all examples work before submitting PR
- Run `terraform fmt` to format code

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## Testing

```bash
# Install dependencies
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Plan changes
terraform plan

# Run tests (if using Terratest)
cd tests
go test -v
```

## Troubleshooting

### Common Issues

**Issue**: "Error 403: Compute Engine API has not been used"
- **Solution**: Enable the Compute Engine API: `gcloud services enable compute.googleapis.com`

**Issue**: "Error 403: Insufficient permissions"
- **Solution**: Ensure your service account has the required IAM roles

**Issue**: "VPC network already exists"
- **Solution**: Import existing network or use a different network name

### Support

For issues and questions:
- Open an issue in the GitHub repository
- Check existing issues for similar problems
- Review Google Cloud documentation

---

**Note**: This is a living document. Please keep it updated as the project evolves.