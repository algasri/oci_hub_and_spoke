/**
 * # Variables for Compute Module
 */

variable "compartment_id" {
  description = "OCID of the compartment where compute instances will be created"
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

variable "prefix" {
  description = "Prefix to use for instance names"
  type        = string
  default     = "oci"
}

variable "assign_public_ip" {
  description = "Whether to assign public IPs to jump servers"
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = ""
}

variable "instances" {
  description = "List of instances to create"
  type = list(object({
    name           = string
    os             = string
    shape          = string
    image_ocid     = string
    subnet         = string
    compartment    = optional(string)
    compartment_id = optional(string)
    is_jump_server = optional(bool, false)
  }))
  default = []
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