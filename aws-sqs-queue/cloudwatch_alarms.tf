# CloudWatch alarms for SQS queue monitoring
# This module creates CloudWatch alarms for SQS with low-latency alerting (faster than Datadog)
# - Defaults: 5m period, 1 evaluation period, datapoints_to_alarm tuned per alarm
# - Only creates alarms in production environment


# CloudWatch alarm for dead letter queue message count
resource "aws_cloudwatch_metric_alarm" "dlq_messages_critical" {
  count = local.cloudwatch_count

  alarm_name        = "${local.alarm_name_prefix}-dlq-messages-critical-${aws_sqs_queue.dlq.name}"
  alarm_description = "Dead letter queue ${aws_sqs_queue.dlq.name} has messages"

  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace   = "AWS/SQS"
  statistic   = "Average"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.dlq_messages_critical
  evaluation_periods  = 2  # Use 2 periods for consistency
  datapoints_to_alarm = 1
  treat_missing_data  = "notBreaching"

  alarm_actions             = data.aws_sns_topic.chatbot_slack[*].arn
  ok_actions                = data.aws_sns_topic.chatbot_slack[*].arn
  insufficient_data_actions = []

  tags = local.tags
}

# CloudWatch alarm for increasing dead letter queue messages
# Uses metric math to detect rate of increase
resource "aws_cloudwatch_metric_alarm" "dlq_messages_increasing" {
  count = local.cloudwatch_count

  alarm_name        = "${local.alarm_name_prefix}-dlq-increasing-${aws_sqs_queue.dlq.name}"
  alarm_description = "Dead letter queue ${aws_sqs_queue.dlq.name} messages are increasing"

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.dlq_messages_increase_threshold
  # Require two consecutive periods breaching; ensure periods >= 2
  evaluation_periods  = max(var.cloudwatch_evaluation_periods, 2)
  datapoints_to_alarm = 2
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

  # Page Rootly in addition to Slack on alarm; only Slack on OK
  # To re-enable Rootly, concat the splats: concat(data.aws_sns_topic.chatbot_slack[*].arn, data.aws_sns_topic.rootly_oncall[*].arn)
  alarm_actions             = data.aws_sns_topic.chatbot_slack[*].arn
  ok_actions                = data.aws_sns_topic.chatbot_slack[*].arn
  insufficient_data_actions = []

  tags = local.tags
}

# CloudWatch alarm for main queue message count (critical)
resource "aws_cloudwatch_metric_alarm" "sqs_messages_critical" {
  count = local.cloudwatch_count

  alarm_name        = "${local.alarm_name_prefix}-messages-critical-${var.queue_name}"
  alarm_description = "SQS queue ${var.queue_name} has high number of messages (critical)"

  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace   = "AWS/SQS"
  statistic   = "Average"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    QueueName = aws_sqs_queue.queue.name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.queue_messages_critical
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = 1
  treat_missing_data  = "notBreaching"

  alarm_actions             = data.aws_sns_topic.chatbot_slack[*].arn
  ok_actions                = data.aws_sns_topic.chatbot_slack[*].arn
  insufficient_data_actions = []

  tags = local.tags
}

# CloudWatch alarm for main queue message count (warning)
resource "aws_cloudwatch_metric_alarm" "sqs_messages_warning" {
  count = local.cloudwatch_count

  alarm_name        = "${local.alarm_name_prefix}-messages-warning-${var.queue_name}"
  alarm_description = "SQS queue ${var.queue_name} has high number of messages (warning)"

  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace   = "AWS/SQS"
  statistic   = "Average"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    QueueName = aws_sqs_queue.queue.name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.queue_messages_warning
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = 1
  treat_missing_data  = "notBreaching"

  alarm_actions             = data.aws_sns_topic.chatbot_slack[*].arn
  ok_actions                = data.aws_sns_topic.chatbot_slack[*].arn
  insufficient_data_actions = []

  tags = local.tags
}

# CloudWatch alarm for main queue message age (critical)
resource "aws_cloudwatch_metric_alarm" "sqs_oldest_message_age_critical" {
  count = local.cloudwatch_count

  alarm_name        = "${local.alarm_name_prefix}-age-critical-${var.queue_name}"
  alarm_description = "SQS queue ${var.queue_name} has old messages exceeding threshold"

  metric_name = "ApproximateAgeOfOldestMessage"
  namespace   = "AWS/SQS"
  statistic   = "Maximum"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    QueueName = aws_sqs_queue.queue.name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.queue_message_age_threshold_seconds
  evaluation_periods  = max(var.cloudwatch_evaluation_periods, 2)
  datapoints_to_alarm = 2
  treat_missing_data  = "notBreaching"

  alarm_actions             = data.aws_sns_topic.chatbot_slack[*].arn
  ok_actions                = data.aws_sns_topic.chatbot_slack[*].arn
  insufficient_data_actions = []

  tags = local.tags
}
