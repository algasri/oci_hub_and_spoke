/**
 * # Variables for Load Balancer Module
 */

variable "compartment_id" {
  description = "OCID of the compartment where load balancers will be created"
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN"
  type        = string
}

variable "subnet_ids" {
  description = "Map of subnet names to OCIDs"
  type        = map(string)
}

variable "network_security_group_ids" {
  description = "Map of subnet names to network security group OCIDs"
  type        = map(string)
  default     = null
}

variable "lb_configs" {
  description = "List of load balancer configurations"
  type = list(object({
    name                      = string
    subnet                    = string
    type                      = string
    shape                     = string
    min_shape                 = optional(number)
    max_shape                 = optional(number)
    backend_type              = string
    ssl_enabled               = optional(bool)
    certificate_name          = optional(string)
    session_persistence_enabled = optional(bool)
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