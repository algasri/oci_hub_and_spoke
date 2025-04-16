/**
 * # OCI Network Module
 * 
 * This module creates VCNs, subnets, and related network resources.
 */

# Create the VCN
resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = var.vcn_name
  dns_label      = replace(var.vcn_name, "-", "")
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create Internet Gateway for the VCN
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_name}-igw"
  enabled        = true
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create NAT Gateway for private subnets
resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_name}-natgw"
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create Service Gateway for OCI Services
resource "oci_core_service_gateway" "service_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_name}-sgw"
  
  services {
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Get all OCI Services
data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# Create Dynamic Routing Gateway if this is the hub VCN
resource "oci_core_drg" "drg" {
  count = var.is_hub ? 1 : 0
  
  compartment_id = var.compartment_id
  display_name   = "${var.vcn_name}-drg"
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Attach DRG to the VCN
resource "oci_core_drg_attachment" "drg_attachment" {
  count = var.is_hub || var.is_spoke ? 1 : 0
  
  drg_id       = var.is_hub ? oci_core_drg.drg[0].id : var.hub_drg_id
  vcn_id       = oci_core_vcn.vcn.id
  display_name = "${var.vcn_name}-drg-attachment"
}

# Create default route table for the VCN
resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id
  display_name               = "${var.vcn_name}-default-rt"
  
  # Route traffic to the internet through the Internet Gateway
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create a route table for private subnets
resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vcn_name}-private-rt"
  
  # Route traffic to the internet through the NAT Gateway
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
  
  # Route traffic to OCI services through the Service Gateway
  route_rules {
    destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.service_gateway.id
  }
  
  # For spoke VCNs, route traffic to other spokes through the hub DRG
  dynamic "route_rules" {
    for_each = var.is_spoke ? [1] : []
    content {
      destination       = "10.0.0.0/8" # This covers all VCNs in our design
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg_attachment.drg_attachment[0].id
    }
  }
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create subnets based on provided configuration
resource "oci_core_subnet" "subnets" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
  }
  
  cidr_block     = each.value.cidr
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = each.value.name
  dns_label      = replace(each.value.name, "-", "")
  
  # Determine if the subnet is public or private based on name pattern
  # If the subnet contains "public" or "hub-access", it's public
  prohibit_public_ip_on_vnic = ! (contains(["public", "hub-access"], lower(each.value.name)) || contains(["hub-public", "hub-access"], each.value.name))
  
  # Use the appropriate route table
  route_table_id = contains(["public", "hub-access"], lower(each.value.name)) ||  contains(["hub-public", "hub-access"], each.value.name) ? oci_core_default_route_table.default_route_table.id : oci_core_route_table.private_route_table.id
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create DRG route distribution for the hub DRG (if this is the hub)
resource "oci_core_drg_route_distribution" "hub_drg_route_distribution" {
  count = var.is_hub ? 1 : 0
  
  drg_id      = oci_core_drg.drg[0].id
  display_name = "${var.vcn_name}-drg-route-distribution"
  distribution_type = "IMPORT"
}

# Create a route distribution statement for the hub DRG
resource "oci_core_drg_route_distribution_statement" "hub_drg_route_distribution_statement" {
  count = var.is_hub ? 1 : 0
  
  drg_route_distribution_id = oci_core_drg_route_distribution.hub_drg_route_distribution[0].id
  action = "ACCEPT"
  priority = 1
  
  match_criteria {
    match_type = "DRG_ATTACHMENT_TYPE"
    attachment_type = "VCN"
  }
}

# Create DRG route table for hub-to-spoke routing
resource "oci_core_drg_route_table" "hub_drg_route_table" {
  count = var.is_hub ? 1 : 0
  
  drg_id       = oci_core_drg.drg[0].id
  display_name = "${var.vcn_name}-drg-rt"
  
  import_drg_route_distribution_id = oci_core_drg_route_distribution.hub_drg_route_distribution[0].id
}

# Update the DRG attachment with the route table
resource "oci_core_drg_attachment_management" "drg_attachment_management" {
  count = var.is_hub ? 1 : 0
  
  drg_attachment_id = oci_core_drg_attachment.drg_attachment[0].id
  display_name    = "${var.vcn_name}-drg-attachment-mgmt"
  
  network_details {
    id   = oci_core_vcn.vcn.id
    type = "VCN"
    
    route_table_id = oci_core_route_table.private_route_table.id
  }
}