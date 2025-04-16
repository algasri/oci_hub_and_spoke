/**
 * # OCI IAM Groups Module
 * 
 * This module creates IAM groups and user assignments.
 */

# Create groups
resource "oci_identity_group" "groups" {
  for_each = {
    for group in var.groups : group.name => group
  }
  
  name        = each.value.name
  description = each.value.description
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Add users to groups
resource "oci_identity_user_group_membership" "user_group_memberships" {
  for_each = {
    for membership in local.memberships : "${membership.user}.${membership.group}" => membership
  }
  
  group_id = oci_identity_group.groups[each.value.group].id
  user_id  = each.value.user_id
}

locals {
  # Flatten the group-user relationships for easier processing
  memberships = flatten([
    for group in var.groups : [
      for user in group.users : {
        group     = group.name
        user      = user
        user_id   = user
      }
    ]
  ])
}