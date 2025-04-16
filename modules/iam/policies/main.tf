/**
 * # OCI IAM Policies Module
 * 
 * This module creates IAM policies for resource access.
 */

# Create policies
resource "oci_identity_policy" "policies" {
  for_each = {
    for policy in var.policies : policy.name => policy
  }
  
  name           = each.value.name
  description    = each.value.description
  compartment_id = lookup(var.compartment_ids, each.value.compartment, var.tenancy_ocid)
  
  statements = each.value.statements
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}