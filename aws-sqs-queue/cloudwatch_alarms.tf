# CloudWatch alarms for SQS queues (production only).
# Warning thresholds notify Slack only; critical thresholds also page on-call via Rootly.

# CloudWatch alarm for dead letter queue message count (warning)
resource "aws_cloudwatch_metric_alarm" "dlq_messages_count_warning" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} - DLQ Messages Count Warning"
  alarm_description = "SQS dead letter queue ${aws_sqs_queue.dlq.name} has messages (> ${var.dlq_messages_count_threshold})."

  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace   = "AWS/SQS"
  statistic   = "Average"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.dlq_messages_count_threshold
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = var.cloudwatch_evaluation_periods
  treat_missing_data  = "notBreaching"

  alarm_actions             = local.alerts_slack_sns_topic_arns
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.tags
}

# CloudWatch alarm for increasing dead letter queue messages (critical)
# Uses metric math to detect rate of increase; RATE() requires >= 2 evaluation periods.
resource "aws_cloudwatch_metric_alarm" "dlq_messages_increasing_critical" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} - DLQ Messages Increasing Critical"
  alarm_description = "SQS dead letter queue ${aws_sqs_queue.dlq.name} messages are increasing (rate > ${var.dlq_messages_increase_threshold}/s)."

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.dlq_messages_increase_threshold
  evaluation_periods  = max(var.cloudwatch_evaluation_periods, 2)
  datapoints_to_alarm = max(var.cloudwatch_evaluation_periods, 2)
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "m1"
    return_data = false

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = var.cloudwatch_period_seconds
      stat        = "Average"

      dimensions = {
        QueueName = aws_sqs_queue.dlq.name
      }
    }
  }

  metric_query {
    id          = "e1"
    return_data = true
    expression  = "RATE(m1)"
    label       = "Message increase rate"
  }

  alarm_actions             = concat(local.alerts_slack_sns_topic_arns, local.alerts_rootly_sns_topic_arns)
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.tags
}

# CloudWatch alarm for main queue message count (warning)
resource "aws_cloudwatch_metric_alarm" "sqs_messages_count_warning" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} - Messages Count Warning"
  alarm_description = "SQS queue ${aws_sqs_queue.queue.name} message count exceeded warning threshold (${var.queue_messages_count_warning_threshold})."

  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace   = "AWS/SQS"
  statistic   = "Average"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    QueueName = aws_sqs_queue.queue.name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.queue_messages_count_warning_threshold
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = var.cloudwatch_evaluation_periods
  treat_missing_data  = "notBreaching"

  alarm_actions             = local.alerts_slack_sns_topic_arns
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.tags
}

# CloudWatch alarm for main queue message count (critical)
resource "aws_cloudwatch_metric_alarm" "sqs_messages_count_critical" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} - Messages Count Critical"
  alarm_description = "SQS queue ${aws_sqs_queue.queue.name} message count exceeded critical threshold (${var.queue_messages_count_critical_threshold})."

  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace   = "AWS/SQS"
  statistic   = "Average"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    QueueName = aws_sqs_queue.queue.name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.queue_messages_count_critical_threshold
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = var.cloudwatch_evaluation_periods
  treat_missing_data  = "notBreaching"

  alarm_actions             = concat(local.alerts_slack_sns_topic_arns, local.alerts_rootly_sns_topic_arns)
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.tags
}

# CloudWatch alarm for main queue oldest message age (warning)
resource "aws_cloudwatch_metric_alarm" "sqs_oldest_message_age_warning" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} - Messages Age Warning"
  alarm_description = "SQS queue ${aws_sqs_queue.queue.name} oldest message age exceeded warning threshold (${var.queue_message_age_threshold_seconds}s)."

  metric_name = "ApproximateAgeOfOldestMessage"
  namespace   = "AWS/SQS"
  statistic   = "Maximum"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    QueueName = aws_sqs_queue.queue.name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.queue_message_age_threshold_seconds
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = var.cloudwatch_evaluation_periods
  treat_missing_data  = "notBreaching"

  alarm_actions             = local.alerts_slack_sns_topic_arns
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.tags
}
