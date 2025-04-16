/**
 * # Variables for Security Module
 */

variable "compartment_id" {
  description = "OCID of the compartment where security resources will be created"
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN"
  type        = string
}

variable "vcn_name" {
  description = "Name of the VCN"
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR block of the VCN"
  type        = string
}

variable "subnets" {
  description = "List of subnets to create security lists for"
  type = list(object({
    name = string
    cidr = string
    security_list_rules = optional(list(object({
      type              = string
      protocol          = string
      port              = optional(number)
      source_cidr       = optional(string)
      destination_cidr  = optional(string)
      description       = string
    })))
  }))
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