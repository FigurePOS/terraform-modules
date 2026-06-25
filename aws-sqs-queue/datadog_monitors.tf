# Datadog DLQ reminder: first notification only after the count stays above threshold for
# dlq_renotify_interval_minutes, then re-notifies on the same interval. CloudWatch handles
# the initial alert.

resource "datadog_monitor" "dlq_messages_count" {
  name    = "${var.service_name} – SQS – DLQ messages reminder (${var.queue_name})"
  type    = "metric alert"
  message = "${local.slack_warning_handle} DLQ still has messages above threshold."
  query   = "min(last_${var.dlq_renotify_interval_minutes}m):aws.sqs.approximate_number_of_messages_visible{queuename:${lower(aws_sqs_queue.dlq.name)},env:${var.env}} > ${var.dlq_messages_count_threshold}"

  monitor_thresholds {
    critical = var.dlq_messages_count_threshold
  }

  notify_no_data      = false
  renotify_interval   = var.dlq_renotify_interval_minutes
  renotify_statuses   = ["alert"]
  require_full_window = false

  tags = ["env:${var.env}", "service:${var.service_name}"]
}
