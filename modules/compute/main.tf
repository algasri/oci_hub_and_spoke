/**
 * # OCI Compute Module
 * 
 * This module creates compute instances including jump servers.
 */

# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Get fault domains
data "oci_identity_fault_domains" "fds" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
}

# Create compute instances (including jump servers)
resource "oci_core_instance" "instances" {
  for_each = {
    for instance in var.instances : instance.name => instance
  }
  
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  # Use the provided compartment_id or the instance-specific one
  compartment_id      = lookup(each.value, "compartment_id", var.compartment_id)
  display_name        = each.value.name
  shape               = each.value.shape
  
  create_vnic_details {
    subnet_id        = lookup(var.subnet_ids, each.value.subnet, null)
    display_name     = "${each.value.name}-vnic"
    assign_public_ip = contains(["public", "hub-access"], lower(each.value.subnet)) ? true : false
    hostname_label   = replace(each.value.name, "-", "")
  }
  
  source_details {
    source_type = "image"
    source_id   = each.value.image_ocid
  }
  
  metadata = each.value.os == "linux" ? {
    ssh_authorized_keys = var.ssh_public_key
  } : {}
  
  # Tag for jump servers
  defined_tags = merge(
    var.defined_tags,
    lookup(each.value, "is_jump_server", false) ? {"Server.Type" = "JumpServer"} : {}
  )
  freeform_tags = merge(
    var.freeform_tags,
    lookup(each.value, "is_jump_server", false) ? {"is_jump_server" = "true"} : {}
  )
}

# Output maps for quick reference
locals {
  jump_servers = {
    for name, instance in oci_core_instance.instances :
    name => instance if lookup(var.instances[name], "is_jump_server", false)
  }
  
  linux_jump_servers = {
    for name, instance in local.jump_servers :
    name => instance if var.instances[name].os == "linux"
  }
  
  windows_jump_servers = {
    for name, instance in local.jump_servers :
    name => instance if var.instances[name].os == "windows"
  }
  
  regular_instances = {
    for name, instance in oci_core_instance.instances :
    name => instance if !lookup(var.instances[name], "is_jump_server", false)
  }
}