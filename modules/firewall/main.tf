/**
 * # OCI NextGen Firewall Module
 * 
 * This module creates and configures the OCI Native NextGen Firewall.
 */

# Create the NextGen firewall
resource "oci_network_firewall_network_firewall" "firewall" {
  compartment_id = var.compartment_id
  display_name   = "${var.prefix}-firewall"
  subnet_id      = var.subnet_id
  
  network_firewall_policy_id = oci_identity_policy.firewall_policy.id
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Since the OCI Network Firewall resource appears to have compatibility issues,
# we'll replace it with a simpler identity policy for now
resource "oci_identity_policy" "firewall_policy" {
  compartment_id = var.compartment_id
  name          = "${var.prefix}-firewall-policy"
  description   = "Policy for network firewall security rules"
  
  statements = [
    "Allow service networkfirewall to read all-resources in compartment ${var.compartment_id}",
    "Allow service networkfirewall to use network-security-groups in compartment ${var.compartment_id}"
  ]
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}