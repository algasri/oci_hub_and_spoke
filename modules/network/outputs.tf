/**
 * # Outputs for Network Module
 */

output "vcn_id" {
  description = "OCID of the created VCN"
  value       = oci_core_vcn.vcn.id
}

output "subnet_ids" {
  description = "Map of subnet names to their OCIDs"
  value       = {
    for name, subnet in oci_core_subnet.subnets : name => subnet.id
  }
}

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.internet_gateway.id
}

output "nat_gateway_id" {
  description = "OCID of the NAT Gateway"
  value       = oci_core_nat_gateway.nat_gateway.id
}

output "service_gateway_id" {
  description = "OCID of the Service Gateway"
  value       = oci_core_service_gateway.service_gateway.id
}

output "drg_id" {
  description = "OCID of the Dynamic Routing Gateway (if created)"
  value       = var.is_hub ? oci_core_drg.drg[0].id : null
}

output "private_route_table_id" {
  description = "OCID of the private route table"
  value       = oci_core_route_table.private_route_table.id
}

output "default_route_table_id" {
  description = "OCID of the default route table"
  value       = oci_core_default_route_table.default_route_table.id
}

output "drg_attachment_id" {
  description = "OCID of the DRG attachment (if created)"
  value       = var.is_hub || var.is_spoke ? oci_core_drg_attachment.drg_attachment[0].id : null
}

output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = oci_core_vcn.vcn.cidr_block
}

output "subnet_cidrs" {
  description = "Map of subnet names to their CIDR blocks"
  value       = {
    for name, subnet in oci_core_subnet.subnets : name => subnet.cidr_block
  }
}