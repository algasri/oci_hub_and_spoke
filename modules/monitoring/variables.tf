/**
 * # Variables for Monitoring Module
 */

variable "tenancy_ocid" {
  description = "OCID of the tenancy"
  type        = string
}

variable "compartment_id" {
  description = "OCID of the compartment where monitoring resources will be created"
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN for flow logs"
  type        = string
  default     = null
}

variable "region" {
  description = "OCI region"
  type        = string
}

variable "prefix" {
  description = "Prefix to use for resource names"
  type        = string
  default     = "oci"
}

variable "cloud_guard_enabled" {
  description = "Whether to enable Cloud Guard"
  type        = bool
  default     = true
}

variable "logging_enabled" {
  description = "Whether to enable Logging"
  type        = bool
  default     = true
}

variable "notification_enabled" {
  description = "Whether to enable Notifications"
  type        = bool
  default     = true
}

variable "notification_email" {
  description = "Email address for notifications"
  type        = string
  default     = null
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