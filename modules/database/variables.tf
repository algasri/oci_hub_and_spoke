/**
 * # Variables for Database Module
 */

variable "compartment_id" {
  description = "OCID of the compartment where the database will be created"
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN"
  type        = string
}

variable "subnet_id" {
  description = "OCID of the subnet where the database will be deployed"
  type        = string
  default     = null
}

variable "default_subnet_id" {
  description = "Default subnet ID to use if subnet_id is not provided"
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix to use for resource names"
  type        = string
  default     = "oci"
}

variable "dbcs_config" {
  description = "Configuration for the Database Cloud Service"
  type = object({
    shape              = string
    db_version         = string
    db_name            = string
    pdb_name           = optional(string)
    db_workload        = optional(string)
    character_set      = optional(string)
    ncharacter_set     = optional(string)
    node_count         = optional(number)
    storage_size_in_gb = optional(number)
  })
}

variable "admin_password" {
  description = "Password for the database administrator"
  type        = string
  sensitive   = true
  default     = "WelcomE123##" # For demonstration only - should be changed in production
}

variable "ssh_public_key" {
  description = "SSH public key for database access"
  type        = string
  default     = ""
}

variable "backup_subnet_id" {
  description = "OCID of the subnet for database backups"
  type        = string
  default     = null
}

variable "backup_network_nsg_ids" {
  description = "List of network security group OCIDs for the backup network"
  type        = list(string)
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