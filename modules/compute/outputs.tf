/**
 * # Outputs for Compute Module
 */

output "linux_jump_details" {
  description = "Details of the Linux jump server"
  value = var.linux_jump != null ? {
    id           = oci_core_instance.linux_jump_server[0].id
    display_name = oci_core_instance.linux_jump_server[0].display_name
    state        = oci_core_instance.linux_jump_server[0].state
    shape        = oci_core_instance.linux_jump_server[0].shape
    private_ip   = oci_core_instance.linux_jump_server[0].private_ip
    public_ip    = oci_core_instance.linux_jump_server[0].public_ip
  } : null
}

output "windows_jump_details" {
  description = "Details of the Windows jump server"
  value = var.windows_jump != null ? {
    id           = oci_core_instance.windows_jump_server[0].id
    display_name = oci_core_instance.windows_jump_server[0].display_name
    state        = oci_core_instance.windows_jump_server[0].state
    shape        = oci_core_instance.windows_jump_server[0].shape
    private_ip   = oci_core_instance.windows_jump_server[0].private_ip
    public_ip    = oci_core_instance.windows_jump_server[0].public_ip
  } : null
}

output "instance_details" {
  description = "Details of created compute instances"
  value = {
    for name, instance in oci_core_instance.instances : name => {
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