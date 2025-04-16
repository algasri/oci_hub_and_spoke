/**
 * # Variables for IAM Groups Module
 */

variable "groups" {
  description = "List of groups to create"
  type = list(object({
    name        = string
    description = string
    users       = list(string)
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