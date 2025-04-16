/**
 * # Outputs for IAM Groups Module
 */

output "group_ids" {
  description = "Map of group names to OCIDs"
  value       = {
    for name, group in oci_identity_group.groups : name => group.id
  }
}

output "group_details" {
  description = "Details of the created groups"
  value       = {
    for name, group in oci_identity_group.groups : name => {
      id          = group.id
      name        = group.name
      description = group.description
      state       = group.state
    }
  }
}

output "user_group_memberships" {
  description = "Details of user group memberships"
  value       = {
    for key, membership in oci_identity_user_group_membership.user_group_memberships : key => {
      id       = membership.id
      group_id = membership.group_id
      user_id  = membership.user_id
    }
  }
}