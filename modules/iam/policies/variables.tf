/**
 * # Variables for IAM Policies Module
 */

variable "tenancy_ocid" {
  description = "OCID of the tenancy"
  type        = string
}

variable "policies" {
  description = "List of policies to create"
  type = list(object({
    name        = string
    description = string
    statements  = list(string)
    compartment = string
  }))
}

variable "compartment_ids" {
  description = "Map of compartment names to OCIDs"
  type        = map(string)
}

variable "freeform_tags" {
  description = "Freeform tags to apply to created resources"
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to apply to created resources"
  type        = map(string)
  default     = {}
}