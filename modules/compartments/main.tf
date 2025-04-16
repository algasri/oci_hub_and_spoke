/**
 * # OCI Compartments Module
 * 
 * This module creates compartments and sub-compartments based on the provided configuration.
 */

# Local variables for compartment processing
locals {
  # Flatten the compartment hierarchy for easier processing
  flatten_compartments = flatten([
    for comp in var.compartments : [
      {
        name        = comp.name
        description = comp.description
        parent_id   = var.tenancy_ocid
        parent_name = "root"
      },
      flatten([
        for sub_comp in lookup(comp, "sub_compartments", []) : [
          {
            name        = sub_comp.name
            description = sub_comp.description
            parent_id   = null # Will be set after parent compartment creation
            parent_name = comp.name
          },
          flatten([
            for sub_sub_comp in lookup(sub_comp, "sub_compartments", []) : [
              {
                name        = sub_sub_comp.name
                description = sub_sub_comp.description
                parent_id   = null # Will be set after parent compartment creation
                parent_name = sub_comp.name
              }
            ]
          ])
        ]
      ])
    ]
  ])
}

# Create top-level compartments
resource "oci_identity_compartment" "top_level" {
  for_each = {
    for idx, comp in local.flatten_compartments : comp.name => comp
    if comp.parent_name == "root"
  }
  
  compartment_id = var.tenancy_ocid
  name           = each.value.name
  description    = each.value.description
  
  enable_delete = var.enable_compartment_delete
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create second-level compartments
resource "oci_identity_compartment" "second_level" {
  depends_on = [oci_identity_compartment.top_level]
  
  for_each = {
    for idx, comp in local.flatten_compartments : comp.name => comp
    if comp.parent_name != "root" && contains(keys(oci_identity_compartment.top_level), comp.parent_name)
  }
  
  compartment_id = oci_identity_compartment.top_level[each.value.parent_name].id
  name           = each.value.name
  description    = each.value.description
  
  enable_delete = var.enable_compartment_delete
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create third-level compartments
resource "oci_identity_compartment" "third_level" {
  depends_on = [oci_identity_compartment.second_level]
  
  for_each = {
    for idx, comp in local.flatten_compartments : comp.name => comp
    if comp.parent_name != "root" && 
       !contains(keys(oci_identity_compartment.top_level), comp.parent_name) && 
       contains(keys(oci_identity_compartment.second_level), comp.parent_name)
  }
  
  compartment_id = oci_identity_compartment.second_level[each.value.parent_name].id
  name           = each.value.name
  description    = each.value.description
  
  enable_delete = var.enable_compartment_delete
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create a map of all compartment names to their OCIDs for reference in other modules
locals {
  compartment_ids = merge(
    { for k, v in oci_identity_compartment.top_level : k => v.id },
    { for k, v in oci_identity_compartment.second_level : k => v.id },
    { for k, v in oci_identity_compartment.third_level : k => v.id },
    { "root" = var.tenancy_ocid }
  )
}