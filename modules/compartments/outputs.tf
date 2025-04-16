/**
 * # Outputs for Compartments Module
 */

output "compartment_ids" {
  description = "Map of compartment names to OCIDs"
  value       = local.compartment_ids
}

output "top_level_compartments" {
  description = "Details of top-level compartments"
  value       = {
    for name, compartment in oci_identity_compartment.top_level : name => {
      id          = compartment.id
      name        = compartment.name
      description = compartment.description
    }
  }
}

output "second_level_compartments" {
  description = "Details of second-level compartments"
  value       = {
    for name, compartment in oci_identity_compartment.second_level : name => {
      id          = compartment.id
      name        = compartment.name
      description = compartment.description
    }
  }
}

output "third_level_compartments" {
  description = "Details of third-level compartments"
  value       = {
    for name, compartment in oci_identity_compartment.third_level : name => {
      id          = compartment.id
      name        = compartment.name
      description = compartment.description
    }
  }
}