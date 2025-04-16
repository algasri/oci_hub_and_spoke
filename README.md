# OCI Hub-and-Spoke Architecture Terraform Project

This project implements a hub-and-spoke network architecture in Oracle Cloud Infrastructure (OCI) using Terraform. It provides a modular approach to creating a secure, scalable, and manageable cloud environment.

## Architecture Overview

The architecture consists of:

1. **Hub VCN**
   - Public subnet for load balancers
   - Private subnet for NextGen Firewall
   - Public subnet for jump servers (Linux and Windows)
   - All traffic from spokes flows through the hub

2. **Spoke VCNs**
   - Each spoke represents an environment (e.g., dev, test, prod)
   - Private subnet for management access with jump servers
   - Private subnet for web resources (load balancers)
   - Private subnet for app resources (compute instances)
   - Private subnet for database resources (DBCS)

3. **Connectivity**
   - Dynamic Routing Gateway (DRG) for hub-to-spoke communication
   - Proper route tables to ensure traffic flow through the hub

## Prerequisites

- Terraform v1.0.0+
- OCI CLI configured
- OCI API keys for Terraform
- Required OCI permissions

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/oci-hub-spoke-terraform.git
   cd oci-hub-spoke-terraform
   ```

2. Copy the example configuration:
   ```bash
   cp examples/input.yaml ./input.yaml
   ```

3. Edit `input.yaml` to match your requirements.

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Create a `terraform.tfvars` file with your OCI credentials:
   ```
   tenancy_ocid     = "ocid1.tenancy.oc1.."
   user_ocid        = "ocid1.user.oc1.."
   fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
   private_key_path = "~/.oci/oci_api_key.pem"
   region           = "us-ashburn-1"
   compartment_id   = "ocid1.compartment.oc1.."
   ssh_public_key   = "ssh-rsa AAAA..."
   ```

6. Plan the deployment:
   ```bash
   terraform plan
   ```

7. Apply the configuration:
   ```bash
   terraform apply
   ```

## Customization

### YAML Configuration

The architecture is defined in a YAML configuration file (`input.yaml`). You can customize:

- Compartment structure
- VCN and subnet CIDR blocks
- Security list rules
- Compute instances (shapes, images)
- Database configurations
- Load balancer settings
- Firewall rules
- IAM policies and groups

Example structure:

```yaml
compartments:
  - name: "non-production"
    description: "Non-production compartment"
    sub_compartments:
      - name: "dev"
        description: "Development resources compartment"
        
hub_vcn:
  name: "hub-vcn"
  cidr: "10.0.0.0/16"
  compartment: "hub"
  subnets:
    # subnet definitions
    
spokes_vcn:
  - name: "spoke1"
    cidr: "10.1.0.0/16"
    compartment: "spoke1"
    # spoke resources
```

### Module Customization

The project is structured in a modular way, making it easy to extend or modify functionality:

- `modules/compartments`: Manages compartment hierarchy
- `modules/network`: Creates VCNs, subnets, and network components
- `modules/security`: Manages security lists and network security groups
- `modules/compute`: Deploys compute instances and jump servers
- `modules/database`: Provisions Oracle Database Cloud Service
- `modules/loadbalancer`: Sets up load balancers
- `modules/firewall`: Configures NextGen Firewall
- `modules/monitoring`: Enables Cloud Guard, logging, and notifications
- `modules/iam`: Manages groups and policies

## Scaling

To add more spoke VCNs, simply extend the `spokes_vcn` section in the YAML file. The modular design allows for easy scaling without modifying the core infrastructure code.

## Security Best Practices

This implementation follows OCI security best practices:

- Proper network segmentation with hub-and-spoke design
- Private subnets for sensitive resources
- Firewall to control traffic flow
- Least privilege IAM policies
- Cloud Guard for security monitoring
- Comprehensive logging and notifications
- Jump servers for secure access

## Maintenance

1. Update the YAML configuration as needed
2. Run `terraform plan` to review changes
3. Apply changes with `terraform apply`
4. Use `terraform destroy` to tear down the infrastructure

## Troubleshooting

- Check Terraform state with `terraform state list`
- Review OCI console for resource status
- Verify route table configurations