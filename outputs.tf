/**
 * # Outputs for OCI Hub-and-Spoke Architecture
 * 
 * This file defines the outputs after deployment.
 */

output "compartment_ids" {
  description = "OCIDs of created compartments"
  value       = module.compartments.compartment_ids
}

output "hub_vcn_id" {
  description = "OCID of the hub VCN"
  value       = module.hub_network.vcn_id
}

output "hub_subnet_ids" {
  description = "OCIDs of hub subnets"
  value       = module.hub_network.subnet_ids
}

output "hub_instances" {
  description = "Details of hub compute instances"
  value       = module.hub_compute.instance_details
  sensitive   = true
}

output "spoke_vcn_ids" {
  description = "OCIDs of the spoke VCNs"
  value       = [for network in module.spoke_networks : network.vcn_id]
}

output "spoke_subnet_ids" {
  description = "OCIDs of spoke subnets"
  value       = [for network in module.spoke_networks : network.subnet_ids]
}

output "spoke_instances" {
  description = "Details of spoke compute instances"
  value       = [for compute in module.spoke_compute : compute.instance_details]
  sensitive   = true
}

output "jump_servers" {
  description = "Details of jump servers"
  value       = [for compute in module.spoke_compute : {
    linux = compute.linux_jump_details
    windows = compute.windows_jump_details
  }]
  sensitive   = true
}

output "loadbalancers" {
  description = "Details of load balancers"
  value       = [for lb in module.spoke_loadbalancers : lb.lb_details]
}

output "databases" {
  description = "Details of databases"
  value       = [for db in module.spoke_databases : db.db_details]
  sensitive   = true
}

output "firewall_id" {
  description = "OCID of the hub firewall"
  value       = module.hub_firewall.firewall_id
}

output "drg_id" {
  description = "OCID of the Dynamic Routing Gateway"
  value       = module.hub_network.drg_id
}