/**
 * # Outputs for Load Balancer Module
 */

output "load_balancer_ids" {
  description = "OCIDs of the load balancers"
  value       = {
    for name, lb in oci_load_balancer_load_balancer.load_balancers : name => lb.id
  }
}

output "backend_set_ids" {
  description = "OCIDs of the backend sets"
  value       = {
    for name, backend_set in oci_load_balancer_backend_set.backend_sets : name => backend_set.id
  }
}

output "listener_ids" {
  description = "OCIDs of the listeners"
  value       = {
    for name, listener in oci_load_balancer_listener.listeners : name => listener.id
  }
}

output "ssl_listener_ids" {
  description = "OCIDs of the SSL listeners"
  value       = {
    for name, listener in oci_load_balancer_listener.ssl_listeners : name => listener.id
  }
}

output "lb_details" {
  description = "Details of the load balancers"
  value       = {
    for name, lb in oci_load_balancer_load_balancer.load_balancers : name => {
      id           = lb.id
      display_name = lb.display_name
      shape        = lb.shape
      ip_addresses = lb.ip_address_details
      is_private   = lb.is_private
      state        = lb.state
    }
  }
}

output "backend_set_names" {
  description = "Names of the backend sets"
  value = {
    for name, backend_set in oci_load_balancer_backend_set.backend_sets : name => backend_set.name
  }
}