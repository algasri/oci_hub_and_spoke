/**
 * # Outputs for IAM Policies Module
 */

output "policy_ids" {
  description = "Map of policy names to OCIDs"
  value       = {
    for name, policy in oci_identity_policy.policies : name => policy.id
  }
}

output "policy_details" {
  description = "Details of the created policies"
  value       = {
    for name, policy in oci_identity_policy.policies : name => {
      id           = policy.id
      name         = policy.name
      description  = policy.description
      statements   = policy.statements
      compartment_id = policy.compartment_id
      state        = policy.state
    }
  }
}