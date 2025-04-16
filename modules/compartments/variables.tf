/**
 * # Variables for Compartments Module
 */

variable "compartments" {
  description = "List of compartments to create"
  type = list(object({
    name             = string
    description      = string
    sub_compartments = optional(list(object({
      name             = string
      description      = string
      sub_compartments = optional(list(object({
        name        = string
        description = string
      })))
    })))
  }))
}

variable "tenancy_ocid" {
  description = "OCID of the tenancy"
  type        = string
}

variable "enable_compartment_delete" {
  description = "Whether to enable delete for compartments"
  type        = bool
  default     = true
}

variable "freeform_tags" {
  description = "Freeform tags to apply to compartments"
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to apply to compartments"
  type        = map(string)
  default     = {}
}