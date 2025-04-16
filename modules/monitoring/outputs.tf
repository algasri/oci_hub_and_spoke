/**
 * # Outputs for Monitoring Module
 */

output "cloud_guard_configuration_id" {
  description = "OCID of the Cloud Guard configuration"
  value       = var.cloud_guard_enabled ? oci_cloud_guard_cloud_guard_configuration.cloud_guard_configuration[0].id : null
}

output "cloud_guard_target_id" {
  description = "OCID of the Cloud Guard target"
  value       = var.cloud_guard_enabled ? oci_cloud_guard_target.tenancy_target[0].id : null
}

output "notification_topic_id" {
  description = "OCID of the notification topic"
  value       = var.notification_enabled ? oci_ons_notification_topic.notification_topic[0].id : null
}

output "notification_subscription_id" {
  description = "OCID of the notification subscription"
  value       = var.notification_enabled && var.notification_email != null ? oci_ons_subscription.email_subscription[0].id : null
}

output "log_group_id" {
  description = "OCID of the log group"
  value       = var.logging_enabled ? oci_logging_log_group.audit_log_group[0].id : null
}

output "vcn_flow_log_id" {
  description = "OCID of the VCN flow log"
  value       = var.logging_enabled ? oci_logging_log.vcn_flow_log[0].id : null
}

output "high_cpu_alarm_id" {
  description = "OCID of the high CPU alarm"
  value       = var.notification_enabled ? oci_monitoring_alarm.high_cpu_alarm[0].id : null
}

output "high_memory_alarm_id" {
  description = "OCID of the high memory alarm"
  value       = var.notification_enabled ? oci_monitoring_alarm.high_memory_alarm[0].id : null
}

output "monitoring_status" {
  description = "Status of monitoring services"
  value = {
    cloud_guard  = var.cloud_guard_enabled ? "ENABLED" : "DISABLED"
    logging      = var.logging_enabled ? "ENABLED" : "DISABLED"
    notification = var.notification_enabled ? "ENABLED" : "DISABLED"
  }
}