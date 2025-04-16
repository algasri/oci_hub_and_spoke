/**
 * # Variables for OCI Hub-and-Spoke Architecture
 * 
 * This file defines the variables used in the Terraform configuration.
 */

variable "config_file_path" {
  description = "Path to the YAML configuration file"
  type        = string
  default     = "input.yaml"
}

variable "tenancy_ocid" {
  description = "OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the user calling the API"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the API private key"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key used for OCI API calls"
  type        = string
}

variable "region" {
  description = "OCI region to deploy resources"
  type        = string
}

variable "compartment_id" {
  description = "OCID of the root compartment"
  type        = string
}

variable "linux_image_id" {
  description = "OCID of the Linux image to use for compute instances"
  type        = string
  default     = "ocid1.image.oc1.iad.aaaaaaaavzjw65d6pqbvgovw3qs4vyb4m3qmzbqafwky6ys44cabgcx63c3a" # Oracle Linux 8
}

variable "windows_image_id" {
  description = "OCID of the Windows image to use for compute instances"
  type        = string
  default     = "ocid1.image.oc1.iad.aaaaaaaawufnve5jxze4xf7orejupw5iq3pms6cuadzjc7klojix6vmk42va" # Windows Server 2019
}

variable "vm_shape" {
  description = "Shape for compute instances"
  type        = string
  default     = "VM.Standard2.1"
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

variable "freeform_tags" {
  description = "Freeform tags to apply to all resources"
  type        = map(string)
  default     = {
    "project" = "hub-spoke-architecture"
  }
}

variable "defined_tags" {
  description = "Defined tags to apply to all resources"
  type        = map(string)
  default     = {}
}