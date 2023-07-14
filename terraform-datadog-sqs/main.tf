locals {
  identifierLabel = var.identifier ? "(${var.identifier})" : ""
}

resource "datadog_monitor" "sqs_number_of_messages_monitor" {
  name = trimspace("${var.service_name_readable} – SQS - Number of messages ${local.identifierLabel}")
  count = var.env == "production" ? 1 : 0
  locked = true
  tags = var.tags
  type = "metric alert"
  message = var.message
  query = "min(last_5m):avg:aws.sqs.approximate_number_of_messages_visible{queuename:${lower(var.queue_name)},env:${var.env}} > ${var.queue_messages_critical}"
  monitor_thresholds {
    warning = var.queue_messages_warning
    critical = var.queue_messages_critical
  }
}

resource "datadog_monitor" "sqs_number_of_messages_dead_letter_monitor" {
  name = trimspace("${var.service_name_readable} – SQS - Number of messages in dead letter ${local.identifierLabel}")
  count = var.env == "production" ? 1 : 0
  locked = true
  tags = var.tags
  type = "metric alert"
  message = var.message
  query = "min(last_5m):avg:aws.sqs.approximate_number_of_messages_visible{queuename:${lower(var.dead_letter_queue_name)},env:${var.env}} > ${var.dead_letter_queue_messages_critical}"
  monitor_thresholds {
    warning = var.dead_letter_queue_messages_warning
    critical = var.dead_letter_queue_messages_critical
  }
  renotify_interval = var.dead_letter_queue_renotify_interval
}
