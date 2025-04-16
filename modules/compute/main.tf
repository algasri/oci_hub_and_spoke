/**
 * # OCI Compute Module
 * 
 * This module creates compute instances including jump servers.
 */

# Create Linux jump server
resource "oci_core_instance" "linux_jump_server" {
  count = var.linux_jump != null ? 1 : 0
  
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "${var.prefix}-linux-jump"
  shape               = var.linux_jump.shape
  
  
  create_vnic_details {
    subnet_id        = lookup(var.subnet_ids, "mgmt", 
                       lookup(var.subnet_ids, "${var.prefix}-mgmt", 
                       lookup(var.subnet_ids, "management", 
                       lookup(var.subnet_ids, "${var.prefix}-management", 
                       values(var.subnet_ids)[0]))))
    display_name     = "${var.prefix}-linux-jump-vnic"
    assign_public_ip = var.assign_public_ip
    hostname_label   = "${var.prefix}-linux-jump"
  }
  
  source_details {
    source_type = "image"
    source_id   = var.linux_jump.image_ocid
  }
  
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create Windows jump server
resource "oci_core_instance" "windows_jump_server" {
  count = var.windows_jump != null ? 1 : 0
  
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "${var.prefix}-windows-jump"
  shape               = var.windows_jump.shape
  
  create_vnic_details {
    subnet_id        = lookup(var.subnet_ids, "mgmt", 
                       lookup(var.subnet_ids, "${var.prefix}-mgmt", 
                       lookup(var.subnet_ids, "management", 
                       lookup(var.subnet_ids, "${var.prefix}-management", 
                       values(var.subnet_ids)[0]))))
    display_name     = "${var.prefix}-windows-jump-vnic"
    assign_public_ip = var.assign_public_ip
    hostname_label   = "${var.prefix}-windows-jump"
  }
  
  source_details {
    source_type = "image"
    source_id   = var.windows_jump.image_ocid
  }
  
  metadata = {
    # Windows-specific initialization can be added here
  }
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create custom instances
resource "oci_core_instance" "instances" {
  for_each = {
    for instance in var.instances : instance.name => instance
  }
  
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = each.value.name
  shape               = each.value.shape
  
  create_vnic_details {
    subnet_id        = var.subnet_ids[each.value.subnet]
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
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Get fault domains
data "oci_identity_fault_domains" "fds" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
}