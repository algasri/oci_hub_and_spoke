/**
 * # Outputs for Security Module
 */

output "security_list_ids" {
  description = "Map of subnet names to their security list OCIDs"
  value       = {
    for name, sl in oci_core_security_list.security_lists : name => sl.id
  }
}

output "default_security_list_id" {
  description = "OCID of the default security list"
  value       = oci_core_default_security_list.default_security_list.id
}

output "network_security_group_ids" {
  description = "Map of subnet names to their network security group OCIDs"
  value       = {
    for name, nsg in oci_core_network_security_group.network_security_groups : name => nsg.id
  }
}