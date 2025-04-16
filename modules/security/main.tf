/**
 * # OCI Security Module
 * 
 * This module creates security lists, network security groups, and related security resources.
 */

# Get VCN details to access default security list ID
data "oci_core_vcn" "vcn" {
  vcn_id = var.vcn_id
}

# Create default security list for the VCN
resource "oci_core_default_security_list" "default_security_list" {
  manage_default_resource_id = data.oci_core_vcn.vcn.default_security_list_id
  display_name               = "${var.vcn_name}-default-sl"
  
  # Allow all outbound traffic
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outbound traffic"
  }
  
  # Allow ICMP traffic within the VCN
  ingress_security_rules {
    protocol    = 1 # ICMP
    source      = var.vcn_cidr
    description = "Allow ICMP traffic within the VCN"
    
    icmp_options {
      type = 3 # Destination Unreachable
      code = 4 # Fragmentation Needed
    }
  }
  
  # Allow established connections from anywhere
  ingress_security_rules {
    protocol    = 6 # TCP
    source      = "0.0.0.0/0"
    description = "Allow established connections from anywhere"
    
    tcp_options {
      min = 1024
      max = 65535
    }
  }
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create security lists for each subnet based on the subnet configuration
resource "oci_core_security_list" "security_lists" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
    if lookup(subnet, "security_list_rules", null) != null
  }
  
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${each.value.name}-sl"
  
  # Default egress rule to allow all outbound traffic
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outbound traffic"
  }
  
  # Create ingress rules based on the security_list_rules configuration
  dynamic "ingress_security_rules" {
    for_each = [
      for rule in lookup(each.value, "security_list_rules", []) :
      rule if lookup(rule, "type", "") == "ingress"
    ]
    
    content {
      protocol    = ingress_security_rules.value.protocol == "all" ? "all" : ingress_security_rules.value.protocol == "tcp" ? "6" : ingress_security_rules.value.protocol == "udp" ? "17" : ingress_security_rules.value.protocol == "icmp" ? "1" :  ingress_security_rules.value.protocol
      source      = lookup(ingress_security_rules.value, "source_cidr", "0.0.0.0/0")
      description = lookup(ingress_security_rules.value, "description", "Ingress rule")
      
      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.protocol == "tcp" && lookup(ingress_security_rules.value, "port", null) != null ? [1] : []
        content {
          min = ingress_security_rules.value.port
          max = ingress_security_rules.value.port
        }
      }
      
      dynamic "udp_options" {
        for_each = ingress_security_rules.value.protocol == "udp" && lookup(ingress_security_rules.value, "port", null) != null ? [1] : []
        content {
          min = ingress_security_rules.value.port
          max = ingress_security_rules.value.port
        }
      }
    }
  }
  
  # Create additional egress rules based on the security_list_rules configuration
  dynamic "egress_security_rules" {
    for_each = [
      for rule in lookup(each.value, "security_list_rules", []) :
      rule if lookup(rule, "type", "") == "egress"
    ]
    
    content {
      protocol         = egress_security_rules.value.protocol == "all" ? "all" : egress_security_rules.value.protocol == "tcp" ? "6" : egress_security_rules.value.protocol == "udp" ? "17" : egress_security_rules.value.protocol == "icmp" ? "1" : egress_security_rules.value.protocol
      destination      = lookup(egress_security_rules.value, "destination_cidr", "0.0.0.0/0")
      description      = lookup(egress_security_rules.value, "description", "Egress rule")
      
      dynamic "tcp_options" {
        for_each = egress_security_rules.value.protocol == "tcp" && lookup(egress_security_rules.value, "port", null) != null ? [1] : []
        content {
          min = egress_security_rules.value.port
          max = egress_security_rules.value.port
        }
      }
      
      dynamic "udp_options" {
        for_each = egress_security_rules.value.protocol == "udp" && lookup(egress_security_rules.value, "port", null) != null ? [1] : []
        content {
          min = egress_security_rules.value.port
          max = egress_security_rules.value.port
        }
      }
    }
  }
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create Network Security Groups for more granular security
resource "oci_core_network_security_group" "network_security_groups" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
  }
  
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${each.value.name}-nsg"
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create NSG rules for web tier
resource "oci_core_network_security_group_security_rule" "web_nsg_rules" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
    if contains(["web", "hub-public"], lower(subnet.name))
  }
  
  network_security_group_id = oci_core_network_security_group.network_security_groups[each.key].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  
  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
  
  description = "Allow HTTPS from anywhere"
}

# Create NSG rules for app tier
resource "oci_core_network_security_group_security_rule" "app_nsg_rules" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
    if contains(["app"], lower(subnet.name))
  }
  
  network_security_group_id = oci_core_network_security_group.network_security_groups[each.key].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  
  source_type = "NETWORK_SECURITY_GROUP"
  source      = oci_core_network_security_group.network_security_groups[replace(each.key, "app", "web")].id
  
  tcp_options {
    destination_port_range {
      min = 8080
      max = 8080
    }
  }
  
  description = "Allow app traffic from web tier"
}

# Create NSG rules for database tier
resource "oci_core_network_security_group_security_rule" "db_nsg_rules" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
    if contains(["db"], lower(subnet.name))
  }
  
  network_security_group_id = oci_core_network_security_group.network_security_groups[each.key].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  
  source_type = "NETWORK_SECURITY_GROUP"
  source      = oci_core_network_security_group.network_security_groups[replace(each.key, "db", "app")].id
  
  tcp_options {
    destination_port_range {
      min = 1521
      max = 1521
    }
  }
  
  description = "Allow database traffic from app tier"
}

# Create NSG rules for management tier
resource "oci_core_network_security_group_security_rule" "mgmt_nsg_rules" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
    if contains(["mgmt", "hub-access"], lower(subnet.name))
  }
  
  network_security_group_id = oci_core_network_security_group.network_security_groups[each.key].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  
  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
  
  description = "Allow SSH access to management subnet"
}