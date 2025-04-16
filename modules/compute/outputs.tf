/**
 * # Outputs for Compute Module
 */

output "instance_details" {
  description = "Details of all created compute instances"
  value = {
    for name, instance in oci_core_instance.instances : name => {
      id           = instance.id
      display_name = instance.display_name
      state        = instance.state
      shape        = instance.shape
      private_ip   = instance.private_ip
      public_ip    = instance.public_ip
      is_jump_server = lookup(var.instances[name], "is_jump_server", false)
    }
  }
}

output "linux_jump_details" {
  description = "Details of the Linux jump servers"
  value = {
    for name, instance in local.linux_jump_servers : name => {
      id           = instance.id
      display_name = instance.display_name
      state        = instance.state
      shape        = instance.shape
      private_ip   = instance.private_ip
      public_ip    = instance.public_ip
    }
  }
}

output "windows_jump_details" {
  description = "Details of the Windows jump servers"
  value = {
    for name, instance in local.windows_jump_servers : name => {
      id           = instance.id
      display_name = instance.display_name
      state        = instance.state
      shape        = instance.shape
      private_ip   = instance.private_ip
      public_ip    = instance.public_ip
    }
  }
}

output "regular_instance_details" {
  description = "Details of non-jump server instances"
  value = {
    for name, instance in local.regular_instances : name => {
      id           = instance.id
      display_name = instance.display_name
      state        = instance.state
      shape        = instance.shape
      private_ip   = instance.private_ip
      public_ip    = instance.public_ip
    }
  }
}

output "availability_domains" {
  description = "List of availability domains"
  value = data.oci_identity_availability_domains.ads.availability_domains[*].name
}

output "fault_domains" {
  description = "List of fault domains"
  value = data.oci_identity_fault_domains.fds.fault_domains[*].name
}