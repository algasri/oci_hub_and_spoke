/**
 * # Variables for Firewall Module
 */

variable "compartment_id" {
  description = "OCID of the compartment where the firewall will be created"
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN"
  type        = string
}

variable "subnet_id" {
  description = "OCID of the subnet where the firewall will be deployed"
  type        = string
}

variable "prefix" {
  description = "Prefix to use for resource names"
  type        = string
  default     = "oci"
}

variable "firewall_config" {
  description = "Configuration for the firewall"
  type = object({
    allowed_sources = optional(list(string), ["0.0.0.0/0"])
    blocked_urls    = optional(list(string), [])
  })
  default = {}
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