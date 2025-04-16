/**
 * # OCI Database Module
 * 
 * This module creates Oracle Database Cloud Service instances.
 */

# Create Database System
resource "oci_database_db_system" "db_system" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  database_edition    = "ENTERPRISE_EDITION"
  display_name        = "${var.prefix}-${var.dbcs_config.db_name}"
  
  shape              = var.dbcs_config.shape
  subnet_id          = var.subnet_id != null ? var.subnet_id : var.default_subnet_id
  ssh_public_keys    = [var.ssh_public_key]
  hostname           = var.dbcs_config.db_name
  data_storage_size_in_gb = var.dbcs_config.storage_size_in_gb != null ? var.dbcs_config.storage_size_in_gb : 256
  node_count         = var.dbcs_config.node_count != null ? var.dbcs_config.node_count : 1
  
  # System details
  cpu_core_count     = lookup(local.shape_core_counts, var.dbcs_config.shape, 2)
  
  # Database details
  db_home {
    display_name  = "${var.prefix}-${var.dbcs_config.db_name}-home"
    database {
      admin_password = var.admin_password
      db_name        = var.dbcs_config.db_name
      db_workload    = var.dbcs_config.db_workload != null ? var.dbcs_config.db_workload : "OLTP"
      character_set  = var.dbcs_config.character_set != null ? var.dbcs_config.character_set : "AL32UTF8"
      ncharacter_set = var.dbcs_config.ncharacter_set != null ? var.dbcs_config.ncharacter_set : "AL16UTF16"
      pdb_name       = var.dbcs_config.pdb_name != null ? var.dbcs_config.pdb_name : "pdb1"
    }
    db_version    = var.dbcs_config.db_version
  }
  
  # Backup details
  backup_subnet_id      = var.backup_subnet_id != null ? var.backup_subnet_id : null
  backup_network_nsg_ids = var.backup_network_nsg_ids != null ? var.backup_network_nsg_ids : null
  
  # Enable automatic backups
  maintenance_window_details {
    preference = "CUSTOM_PREFERENCE"
    days_of_week {
      name = "SUNDAY"
    }
    hours_of_day       = ["0"]
    lead_time_in_weeks = 1
  }
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Get information about available shapes
locals {
  # Map of shapes to their default core counts
  shape_core_counts = {
    "VM.Standard2.1"   = 1
    "VM.Standard2.2"   = 2
    "VM.Standard2.4"   = 4
    "VM.Standard2.8"   = 8
    "VM.Standard2.16"  = 16
    "VM.Standard2.24"  = 24
  }
}

# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}