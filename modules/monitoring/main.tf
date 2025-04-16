/**
 * # OCI Monitoring Module
 * 
 * This module configures Cloud Guard, Logging, and Notifications.
 */

# Enable Cloud Guard
resource "oci_cloud_guard_cloud_guard_configuration" "cloud_guard_configuration" {
  count = var.cloud_guard_enabled ? 1 : 0
  
  compartment_id        = var.tenancy_ocid
  reporting_region      = var.region
  status                = "ENABLED"
  self_manage_resources = false
}

# Create a Cloud Guard target for the tenancy
resource "oci_cloud_guard_target" "tenancy_target" {
  count = var.cloud_guard_enabled ? 1 : 0
  
  compartment_id       = var.tenancy_ocid
  display_name         = "TenancyTarget"
  target_resource_id   = var.tenancy_ocid
  target_resource_type = "COMPARTMENT"
  
  # Use the default detector recipe
  target_detector_recipes {
    detector_recipe_id = data.oci_cloud_guard_detector_recipes.configuration_detector_recipe[0].detector_recipe_collection[0].items[0].id
  }
  
  target_detector_recipes {
    detector_recipe_id = data.oci_cloud_guard_detector_recipes.activity_detector_recipe[0].detector_recipe_collection[0].items[0].id
  }
  
  target_detector_recipes {
    detector_recipe_id = data.oci_cloud_guard_detector_recipes.threat_detector_recipe[0].detector_recipe_collection[0].items[0].id
  }
  
  # Use the default responder recipe
  target_responder_recipes {
    responder_recipe_id = data.oci_cloud_guard_responder_recipes.responder_recipe[0].responder_recipe_collection[0].items[0].id
  }
  
  depends_on = [oci_cloud_guard_cloud_guard_configuration.cloud_guard_configuration]
}

# Get the default configuration detector recipe
data "oci_cloud_guard_detector_recipes" "configuration_detector_recipe" {
  count = var.cloud_guard_enabled ? 1 : 0
  
  compartment_id = var.tenancy_ocid
  
  filter {
    name   = "display_name"
    values = ["OCI Configuration Detector Recipe"]
  }
}

# Get the default activity detector recipe
data "oci_cloud_guard_detector_recipes" "activity_detector_recipe" {
  count = var.cloud_guard_enabled ? 1 : 0
  
  compartment_id = var.tenancy_ocid
  
  filter {
    name   = "display_name"
    values = ["OCI Activity Detector Recipe"]
  }
}

# Get the default threat detector recipe
data "oci_cloud_guard_detector_recipes" "threat_detector_recipe" {
  count = var.cloud_guard_enabled ? 1 : 0
  
  compartment_id = var.tenancy_ocid
  
  filter {
    name   = "display_name"
    values = ["OCI Threat Detector Recipe"]
  }
}

# Get the default responder recipe
data "oci_cloud_guard_responder_recipes" "responder_recipe" {
  count = var.cloud_guard_enabled ? 1 : 0
  
  compartment_id = var.tenancy_ocid
  
  filter {
    name   = "display_name"
    values = ["OCI Responder Recipe"]
  }
}

# Create a notification topic
resource "oci_ons_notification_topic" "notification_topic" {
  count = var.notification_enabled ? 1 : 0
  
  compartment_id = var.compartment_id
  name           = "${var.prefix}-notifications"
  description    = "Notification topic for infrastructure alerts"
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create a subscription for email notifications
resource "oci_ons_subscription" "email_subscription" {
  count = var.notification_enabled && var.notification_email != null ? 1 : 0
  
  compartment_id = var.compartment_id
  topic_id       = oci_ons_notification_topic.notification_topic[0].id
  endpoint       = var.notification_email
  protocol       = "EMAIL"
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create a service connector for audit logs
resource "oci_logging_log_group" "audit_log_group" {
  count = var.logging_enabled ? 1 : 0
  
  compartment_id = var.compartment_id
  display_name   = "${var.prefix}-audit-logs"
  description    = "Log group for audit logs"
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create a log for VCN flow logs
resource "oci_logging_log" "vcn_flow_log" {
  count = var.logging_enabled ? 1 : 0
  
  display_name = "${var.prefix}-vcn-flow-logs"
  log_group_id = oci_logging_log_group.audit_log_group[0].id
  log_type     = "SERVICE"
  
  configuration {
    source {
      category    = "all"
      resource    = var.vcn_id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_id
  }
  
  is_enabled         = true
  retention_duration = 30
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create an alarm for high CPU usage
resource "oci_monitoring_alarm" "high_cpu_alarm" {
  count = var.notification_enabled ? 1 : 0
  
  compartment_id        = var.compartment_id
  display_name          = "${var.prefix}-high-cpu-alarm"
  destinations          = [oci_ons_notification_topic.notification_topic[0].id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_computeagent"
  query                 = "CpuUtilization[1m].mean() > 80"
  severity              = "CRITICAL"
  
  body    = "High CPU usage detected in the environment"
  message_format = "ONS_OPTIMIZED"
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create an alarm for high memory usage
resource "oci_monitoring_alarm" "high_memory_alarm" {
  count = var.notification_enabled ? 1 : 0
  
  compartment_id        = var.compartment_id
  display_name          = "${var.prefix}-high-memory-alarm"
  destinations          = [oci_ons_notification_topic.notification_topic[0].id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_computeagent"
  query                 = "MemoryUtilization[1m].mean() > 80"
  severity              = "CRITICAL"
  
  body    = "High memory usage detected in the environment"
  message_format = "ONS_OPTIMIZED"
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}