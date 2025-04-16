/**
 * # Outputs for Firewall Module
 */

output "firewall_id" {
  description = "OCID of the created firewall"
  value       = oci_network_firewall_network_firewall.firewall.id
}

output "firewall_policy_id" {
  description = "OCID of the firewall policy"
  value       = oci_identity_policy.firewall_policy.id
}

output "firewall_details" {
  description = "Details of the firewall"
  value = {
    id           = oci_network_firewall_network_firewall.firewall.id
    display_name = oci_network_firewall_network_firewall.firewall.display_name
    state        = oci_network_firewall_network_firewall.firewall.state
    subnet_id    = oci_network_firewall_network_firewall.firewall.subnet_id
    policy_id    = oci_identity_policy.firewall_policy.id
  }
}

output "firewall_policy_details" {
  description = "Details of the firewall policy"
  value = {
    id           = oci_identity_policy.firewall_policy.id
    name         = oci_identity_policy.firewall_policy.name
    description  = oci_identity_policy.firewall_policy.description
    statements   = oci_identity_policy.firewall_policy.statements
    state        = oci_identity_policy.firewall_policy.state
  }
}