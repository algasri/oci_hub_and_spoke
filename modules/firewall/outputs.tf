/**
 * # Outputs for Firewall Module
 */

output "firewall_id" {
  description = "OCID of the created firewall"
  value       = oci_network_firewall_network_firewall.firewall.id
}

output "firewall_policy_id" {
  description = "OCID of the firewall policy"
  value       = oci_network_firewall_network_firewall_policy.firewall_policy.id
}

output "firewall_details" {
  description = "Details of the firewall"
  value = {
    id           = oci_network_firewall_network_firewall.firewall.id
    display_name = oci_network_firewall_network_firewall.firewall.display_name
    state        = oci_network_firewall_network_firewall.firewall.lifecycle_state
    subnet_id    = oci_network_firewall_network_firewall.firewall.subnet_id
    policy_id    = oci_network_firewall_network_firewall.firewall.network_firewall_policy_id
  }
}

output "firewall_policy_details" {
  description = "Details of the firewall policy"
  value = {
    id           = oci_network_firewall_network_firewall_policy.firewall_policy.id
    display_name = oci_network_firewall_network_firewall_policy.firewall_policy.display_name
    state        = oci_network_firewall_network_firewall_policy.firewall_policy.lifecycle_state
  }
}