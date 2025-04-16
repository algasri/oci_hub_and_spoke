/**
 * # OCI Load Balancer Module
 * 
 * This module creates load balancers for web and application tiers.
 */

# Create load balancers
resource "oci_load_balancer_load_balancer" "load_balancers" {
  for_each = {
    for lb in var.lb_configs : lb.name => lb
  }
  
  compartment_id = var.compartment_id
  display_name   = each.value.name
  shape          = each.value.shape
  subnet_ids     = [var.subnet_ids[each.value.subnet]]
  
  # If shape is flexible, configure shape details
  dynamic "shape_details" {
    for_each = each.value.shape == "flexible" ? [1] : []
    content {
      minimum_bandwidth_in_mbps = each.value.min_shape
      maximum_bandwidth_in_mbps = each.value.max_shape
    }
  }
  
  # Set whether the load balancer is private
  is_private = each.value.type == "private" ? true : false
  
  # Configure network security groups if provided
  network_security_group_ids = var.network_security_group_ids != null ? [
    var.network_security_group_ids[each.value.subnet]
  ] : null
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create backend sets for the load balancers
resource "oci_load_balancer_backend_set" "backend_sets" {
  for_each = {
    for lb in var.lb_configs : lb.name => lb
  }
  
  name             = "${each.value.name}-backend-set"
  load_balancer_id = oci_load_balancer_load_balancer.load_balancers[each.key].id
  policy           = "ROUND_ROBIN"
  
  # Configure health check
  health_checker {
    protocol          = "HTTP"
    port              = each.value.backend_type == "web" ? 80 : 8080
    url_path          = "/health"
    interval_ms       = 10000
    timeout_in_millis = 3000
    retries           = 3
  }
  
  # Configure session persistence if needed
  dynamic "session_persistence_configuration" {
    for_each = each.value.session_persistence_enabled == true ? [1] : []
    content {
      cookie_name      = "${each.value.name}-session"
      disable_fallback = false
    }
  }
}

# Create listeners for the load balancers
resource "oci_load_balancer_listener" "listeners" {
  for_each = {
    for lb in var.lb_configs : lb.name => lb
  }
  
  load_balancer_id         = oci_load_balancer_load_balancer.load_balancers[each.key].id
  name                     = "${each.value.name}-listener"
  default_backend_set_name = oci_load_balancer_backend_set.backend_sets[each.key].name
  port                     = each.value.backend_type == "web" ? 80 : 8080
  protocol                 = "HTTP"
  
  # Configure connection configuration if needed
  connection_configuration {
    idle_timeout_in_seconds = 60
  }
}

# Create SSL listeners if SSL is enabled
resource "oci_load_balancer_listener" "ssl_listeners" {
  for_each = {
    for lb in var.lb_configs : lb.name => lb
    if lookup(lb, "ssl_enabled", false) == true && lookup(lb, "certificate_name", null) != null
  }
  
  load_balancer_id         = oci_load_balancer_load_balancer.load_balancers[each.key].id
  name                     = "${each.value.name}-ssl-listener"
  default_backend_set_name = oci_load_balancer_backend_set.backend_sets[each.key].name
  port                     = 443
  protocol                 = "HTTP"
  
  ssl_configuration {
    certificate_name        = each.value.certificate_name
    verify_peer_certificate = false
  }
  
  # Configure connection configuration if needed
  connection_configuration {
    idle_timeout_in_seconds = 60
  }
}

# Add backends to the backend sets (this would normally be done in a separate process
# after instance creation, but included here for completeness)
resource "oci_load_balancer_backend" "backends" {
  for_each = {
    for backend in local.backends : "${backend.lb_name}.${backend.instance_name}" => backend
  }
  
  load_balancer_id = oci_load_balancer_load_balancer.load_balancers[each.value.lb_name].id
  backendset_name  = oci_load_balancer_backend_set.backend_sets[each.value.lb_name].name
  ip_address       = each.value.ip_address
  port             = each.value.backend_port
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

locals {
  # This would be populated dynamically based on instance creation
  # For now, it's an empty list as we don't have actual backend instances yet
  backends = []
  
  # Example of how backends would be defined:
  # backends = [
  #   {
  #     lb_name      = "web-ilb"
  #     instance_name = "instance1"
  #     ip_address   = "10.1.2.10"
  #     backend_port = 80
  #   },
  #   {
  #     lb_name      = "app-ilb"
  #     instance_name = "instance2"
  #     ip_address   = "10.1.3.10"
  #     backend_port = 8080
  #   }
  # ]
}