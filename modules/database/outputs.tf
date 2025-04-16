/**
 * # Outputs for Database Module
 */

output "db_system_id" {
  description = "OCID of the database system"
  value       = oci_database_db_system.db_system.id
}

output "db_home_id" {
  description = "OCID of the database home"
  value       = oci_database_db_system.db_system.db_home[0].id
}

output "database_id" {
  description = "OCID of the database"
  value       = oci_database_db_system.db_system.db_home[0].database[0].id
}

output "db_node_id" {
  description = "OCID of the primary database system"
  value       = oci_database_db_system.db_system.id
}

output "db_details" {
  description = "Details of the database system"
  value = {
    id            = oci_database_db_system.db_system.id
    display_name  = oci_database_db_system.db_system.display_name
    shape         = oci_database_db_system.db_system.shape
    hostname      = oci_database_db_system.db_system.hostname
    domain        = oci_database_db_system.db_system.domain
    version       = oci_database_db_system.db_system.db_home[0].db_version
    database_name = oci_database_db_system.db_system.db_home[0].database[0].db_name
    db_unique_name = oci_database_db_system.db_system.db_home[0].database[0].db_unique_name
    pdb_name      = oci_database_db_system.db_system.db_home[0].database[0].pdb_name
    state         = oci_database_db_system.db_system.state
  }
  sensitive   = true
}

output "connection_string" {
  description = "Connection string for the database"
  value       = "${oci_database_db_system.db_system.hostname}.${oci_database_db_system.db_system.domain}:1521/${oci_database_db_system.db_system.db_home[0].database[0].db_unique_name}"
  sensitive   = true
}

output "scan_dns_name" {
  description = "SCAN DNS name for RAC database"
  value       = oci_database_db_system.db_system.scan_dns_name
}

output "listener_port" {
  description = "Database listener port"
  value       = 1521
}