# Grafana DLQ reminder: pending for dlq_renotify_interval_minutes, then Slack
# re-notifies every 24h via the monitoring policy matching destination + repeat=24h.
# CloudWatch handles the initial alert.

resource "grafana_rule_group" "dlq_messages_count" {
  name             = local.grafana_dlq_group_name
  folder_uid       = var.grafana_folder_uid
  interval_seconds = local.grafana_eval_interval_seconds

  rule {
    name           = "${var.service_name} – SQS – DLQ messages reminder (${var.queue_name})"
    condition      = "C"
    for            = "${var.dlq_renotify_interval_minutes}m"
    no_data_state  = "OK"
    exec_err_state = "KeepLast"
    is_paused      = false

    annotations = {
      summary     = "DLQ still has messages above threshold."
      description = "${aws_sqs_queue.dlq.name} has stayed above ${var.dlq_messages_count_threshold} visible messages for ${var.dlq_renotify_interval_minutes}m (${var.env})."
    }

    labels = {
      service     = var.service_name
      env         = var.env
      kind        = "sqs-dlq-reminder"
      destination = "slack-platform-warnings"
      repeat      = "24h"
    }

    data {
      ref_id         = "A"
      datasource_uid = local.grafana_cloudwatch_datasource_uid

      relative_time_range {
        from = local.grafana_lookback_seconds
        to   = 0
      }

      model = jsonencode({
        refId            = "A"
        hide             = false
        intervalMs       = 60000
        maxDataPoints    = 2
        queryMode        = "Metrics"
        metricQueryType  = 0
        metricEditorMode = 0
        matchExact       = true
        region           = "default"
        namespace        = "AWS/SQS"
        metricName       = "ApproximateNumberOfMessagesVisible"
        statistic        = "Average"
        period           = tostring(local.grafana_lookback_seconds)
        dimensions = {
          QueueName = [aws_sqs_queue.dlq.name]
        }
        datasource = {
          type = "cloudwatch"
          uid  = local.grafana_cloudwatch_datasource_uid
        }
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        refId      = "B"
        type       = "reduce"
        expression = "A"
        reducer    = "last"
        settings = {
          mode = "dropNN"
        }
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        refId      = "C"
        type       = "threshold"
        expression = "B"
        conditions = [
          {
            evaluator = {
              type   = "gt"
              params = [var.dlq_messages_count_threshold]
            }
          },
        ]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
      })
    }
  }
}
