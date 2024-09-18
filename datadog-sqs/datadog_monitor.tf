locals {
  count           = var.env == "production" ? 1 : 0
  identifierLabel = var.identifier != "" ? "(${var.identifier})" : ""

  oncall_handle        = "@webhook-rootly"
  slack_warning_handle = "@slack-platform-warnings"
}

data "datadog_role" "admin_role" {
  filter = "Admin"
}

resource "datadog_monitor" "sqs_number_of_messages_monitor" {
  count = local.count

  name    = trimspace("${var.service_name} – SQS - Total number of messages ${local.identifierLabel}")
  type    = "metric alert"
  message = "{{#is_alert}}${local.oncall_handle} ${local.slack_warning_handle}{{/is_alert}} {{#is_alert_recovery}}${local.oncall_handle} ${local.slack_warning_handle}{{/is_alert_recovery}} ${var.total_number_message}"
  query   = "avg(last_1h):aws.sqs.approximate_number_of_messages_visible{queuename:${lower(var.queue_name)},env:${var.env}}.rollup(min, ${var.queue_rollup}) > ${var.queue_messages_critical}"
  monitor_thresholds {
    warning  = var.queue_messages_warning
    critical = var.queue_messages_critical
  }

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = var.tags
}

resource "datadog_monitor" "sqs_number_of_messages_dead_letter_monitor" {
  count = local.count

  name    = trimspace("${var.service_name} – SQS - Total number of messages in dead letter ${local.identifierLabel}")
  type    = "metric alert"
  message = "{{#is_alert}}${local.slack_warning_handle}{{/is_alert}} {{#is_alert_recovery}}${local.slack_warning_handle}{{/is_alert_recovery}}"
  query   = "avg(last_1h):aws.sqs.approximate_number_of_messages_visible{queuename:${lower(var.dead_letter_queue_name)},env:${var.env}}.rollup(min, ${var.dead_letter_queue_rollup}) > ${var.dead_letter_queue_messages_critical}"
  monitor_thresholds {
    critical = var.dead_letter_queue_messages_critical
  }
  renotify_interval = var.dead_letter_queue_renotify_interval

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = var.tags
}

resource "datadog_monitor" "sqs_increased_number_of_messages_dead_letter_monitor" {
  count = local.count

  name    = trimspace("${var.service_name} – SQS - Increased number of messages in dead letter ${local.identifierLabel}")
  type    = "metric alert"
  message = "{{#is_alert}}${local.oncall_handle}{{/is_alert}} {{#is_alert_recovery}}${local.oncall_handle}{{/is_alert_recovery}}"
  # the query means positive change in amount of messages in last X seconds
  query = "avg(last_1h):monotonic_diff(aws.sqs.approximate_number_of_messages_visible{queuename:${lower(var.dead_letter_queue_name)},env:${var.env}}.rollup(avg, ${var.dead_letter_queue_rollup})) > ${var.dead_letter_queue_increased_messages_critical}"
  monitor_thresholds {
    critical = var.dead_letter_queue_increased_messages_critical
  }
  renotify_interval = var.dead_letter_queue_increased_renotify_interval

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = var.tags
}
