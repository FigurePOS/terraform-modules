# CloudWatch alarms for Lambda function monitoring.
# Warning thresholds notify Slack only.

locals {
  lambda_alarm_tags = merge(var.tags, { Service = var.service_name })
}

# CloudWatch alarm for Lambda errors (warning)
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} ${var.function_name} - Errors Warning"
  alarm_description = "Lambda function ${var.function_name} errors exceeded warning threshold (${var.lambda_errors_alarm_warning_threshold})."

  metric_name = "Errors"
  namespace   = "AWS/Lambda"
  statistic   = "Sum"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.lambda_errors_alarm_warning_threshold
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = var.cloudwatch_evaluation_periods
  treat_missing_data  = "notBreaching"

  alarm_actions             = local.alerts_slack_sns_topic_arns
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.lambda_alarm_tags
}

# CloudWatch alarm for Lambda throttles (warning)
resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} ${var.function_name} - Throttles Warning"
  alarm_description = "Lambda function ${var.function_name} throttles exceeded warning threshold (${var.lambda_throttles_alarm_warning_threshold})."

  metric_name = "Throttles"
  namespace   = "AWS/Lambda"
  statistic   = "Sum"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.lambda_throttles_alarm_warning_threshold
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = var.cloudwatch_evaluation_periods
  treat_missing_data  = "notBreaching"

  alarm_actions             = local.alerts_slack_sns_topic_arns
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.lambda_alarm_tags
}

# CloudWatch alarm for Lambda duration approaching timeout (warning)
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} ${var.function_name} - Duration Warning"
  alarm_description = "Lambda function ${var.function_name} duration exceeded warning threshold (${var.lambda_duration_alarm_warning_threshold_percentage}% of ${var.timeout}s)."

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.timeout * 1000 * var.lambda_duration_alarm_warning_threshold_percentage / 100 # Convert to milliseconds
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = var.cloudwatch_evaluation_periods
  treat_missing_data  = "notBreaching"

  metric_name = "Duration"
  namespace   = "AWS/Lambda"
  statistic   = "Maximum"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }

  alarm_actions             = local.alerts_slack_sns_topic_arns
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.lambda_alarm_tags
}

# CloudWatch alarm for Lambda concurrent executions (warning)
resource "aws_cloudwatch_metric_alarm" "lambda_concurrent_executions" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} ${var.function_name} - Concurrent Executions Warning"
  alarm_description = "Lambda function ${var.function_name} concurrent executions exceeded warning threshold (${var.lambda_concurrent_executions_alarm_warning_threshold})."

  metric_name = "ConcurrentExecutions"
  namespace   = "AWS/Lambda"
  statistic   = "Maximum"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.lambda_concurrent_executions_alarm_warning_threshold
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = var.cloudwatch_evaluation_periods
  treat_missing_data  = "notBreaching"

  alarm_actions             = local.alerts_slack_sns_topic_arns
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.lambda_alarm_tags
}

# CloudWatch alarm for Lambda error rate (warning)
# Uses metric math to calculate error rate as percentage of invocations.
resource "aws_cloudwatch_metric_alarm" "lambda_error_rate" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} ${var.function_name} - Error Rate Warning"
  alarm_description = "Lambda function ${var.function_name} error rate exceeded warning threshold (${var.lambda_error_rate_alarm_warning_threshold}%)."

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.lambda_error_rate_alarm_warning_threshold
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = var.cloudwatch_evaluation_periods
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "errors"
    return_data = false

    metric {
      metric_name = "Errors"
      namespace   = "AWS/Lambda"
      period      = var.cloudwatch_period_seconds
      stat        = "Sum"

      dimensions = {
        FunctionName = aws_lambda_function.this.function_name
      }
    }
  }

  metric_query {
    id          = "invocations"
    return_data = false

    metric {
      metric_name = "Invocations"
      namespace   = "AWS/Lambda"
      period      = var.cloudwatch_period_seconds
      stat        = "Sum"

      dimensions = {
        FunctionName = aws_lambda_function.this.function_name
      }
    }
  }

  metric_query {
    id          = "error_rate"
    return_data = true
    expression  = "IF(invocations > 0, 100 * errors / invocations, 0)"
    label       = "Error rate (%)"
  }

  alarm_actions             = local.alerts_slack_sns_topic_arns
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.lambda_alarm_tags
}
