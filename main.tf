/**
 * # OCI Hub-and-Spoke Architecture
 * 
 * This Terraform project implements a hub-and-spoke architecture on Oracle Cloud Infrastructure.
 */

locals {
  # Parse YAML configuration file
  config = yamldecode(file(var.config_file_path))
  
  # Extract compartment configurations
  compartments = local.config.compartments
  
  # Extract hub VCN configurations
  hub_vcn = local.config.hub_vcn
  
  # Extract spoke VCN configurations
  spokes_vcn = local.config.spokes_vcn
  
  # Extract IAM configurations
  groups = local.config.groups
  policies = local.config.policies
  
  # Extract monitoring configurations
  cloud_guard = local.config.cloud_guard
  logging = local.config.logging
  notification = local.config.notification
}

# Create all compartments
module "compartments" {
  source = "./modules/compartments"
  
  compartments = local.compartments
}

# Create hub VCN and associated resources
module "hub_network" {
  source = "./modules/network"
  
  vcn_name = local.hub_vcn.name
  vcn_cidr = local.hub_vcn.cidr
  compartment_id = module.compartments.compartment_ids[local.hub_vcn.compartment]
  subnets = local.hub_vcn.subnets
  
  depends_on = [module.compartments]
}

# Create hub security lists
module "hub_security" {
  source = "./modules/security"
  
  compartment_id = module.compartments.compartment_ids[local.hub_vcn.compartment]
  vcn_id = module.hub_network.vcn_id
  subnets = local.hub_vcn.subnets
  
  depends_on = [module.hub_network]
}

# Create hub compute instances
module "hub_compute" {
  source = "./modules/compute"
  
  compartment_id = module.compartments.compartment_ids[local.hub_vcn.compartment]
  vcn_id = module.hub_network.vcn_id
  subnet_ids = module.hub_network.subnet_ids
  instances = local.hub_vcn.instances
  
  depends_on = [module.hub_security]
}

# Create hub firewall
module "hub_firewall" {
  source = "./modules/firewall"
  
  compartment_id = module.compartments.compartment_ids[local.hub_vcn.compartment]
  vcn_id = module.hub_network.vcn_id
  subnet_id = module.hub_network.subnet_ids[local.hub_vcn.firewall.subnet]
  
  depends_on = [module.hub_network]
}

# Create spoke VCNs and associated resources
module "spoke_networks" {
  source = "./modules/network"
  count = length(local.spokes_vcn)
  
  vcn_name = local.spokes_vcn[count.index].name
  vcn_cidr = local.spokes_vcn[count.index].cidr
  compartment_id = module.compartments.compartment_ids[local.spokes_vcn[count.index].compartment]
  subnets = local.spokes_vcn[count.index].subnets
  
  # Set up DRG attachments and route tables for hub connectivity
  hub_vcn_id = module.hub_network.vcn_id
  is_spoke = true
  
  depends_on = [module.compartments, module.hub_network]
}

# Create spoke security lists
module "spoke_security" {
  source = "./modules/security"
  count = length(local.spokes_vcn)
  
  compartment_id = module.compartments.compartment_ids[local.spokes_vcn[count.index].compartment]
  vcn_id = module.spoke_networks[count.index].vcn_id
  vcn_name = module.spoke_networks[count.index].vcn_name
  vcn_cidr = module.spoke_networks[count.index].vcn_cidr
  subnets = local.spokes_vcn[count.index].subnets
  
  depends_on = [module.spoke_networks]
}

# Create spoke compute instances (including jump servers)
module "spoke_compute" {
  source = "./modules/compute"
  count = length(local.spokes_vcn)
  
  compartment_id = module.compartments.compartment_ids[local.spokes_vcn[count.index].compartment]
  vcn_id = module.spoke_networks[count.index].vcn_id
  subnet_ids = module.spoke_networks[count.index].subnet_ids
  
  # Jump servers
  linux_jump = local.spokes_vcn[count.index].jump_servers.linux
  windows_jump = local.spokes_vcn[count.index].jump_servers.windows
  
  # Custom instances
  instances = lookup(local.spokes_vcn[count.index], "instances", [])
  
  depends_on = [module.spoke_security]
}

# Create spoke databases
module "spoke_databases" {
  source = "./modules/database"
  count = length(local.spokes_vcn)
  
  compartment_id = module.compartments.compartment_ids[local.spokes_vcn[count.index].compartment]
  vcn_id = module.spoke_networks[count.index].vcn_id
  subnet_id = module.spoke_networks[count.index].subnet_ids["db"]
  dbcs_config = local.spokes_vcn[count.index].dbcs
  
  depends_on = [module.spoke_networks]
}

# Create spoke load balancers
module "spoke_loadbalancers" {
  source = "./modules/loadbalancer"
  count = length(local.spokes_vcn)
  
  compartment_id = module.compartments.compartment_ids[local.spokes_vcn[count.index].compartment]
  vcn_id = module.spoke_networks[count.index].vcn_id
  subnet_ids = module.spoke_networks[count.index].subnet_ids
  lb_configs = local.spokes_vcn[count.index].loadbalancers
  
  depends_on = [module.spoke_networks]
}

# Create IAM groups
module "iam_groups" {
  source = "./modules/iam/groups"
  
  groups = local.groups
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create IAM policies
module "iam_policies" {
  source = "./modules/iam/policies"
  
  tenancy_ocid = var.tenancy_ocid
  policies = local.policies
  compartment_ids = module.compartments.compartment_ids
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
  
  depends_on = [module.iam_groups]
}

# Set up monitoring and notifications
module "monitoring" {
  source = "./modules/monitoring"
  
  tenancy_ocid = var.tenancy_ocid
  compartment_id = var.compartment_id
  region = var.region
  vcn_id = module.hub_network.vcn_id
  prefix = "hub-spoke"
  
  cloud_guard_enabled = local.cloud_guard.enable
  logging_enabled = local.logging.enable
  notification_enabled = local.notification.enable
  notification_email = local.notification.email
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
  
  depends_on = [
    module.hub_network,
    module.spoke_networks,
    module.hub_compute,
    module.spoke_compute,
    module.spoke_databases,
    module.spoke_loadbalancers
  ]
}