# CloudWatch alarms for Lambda function monitoring
# - Defaults: 1m period, 1 evaluation period, datapoints_to_alarm tuned per alarm

# CloudWatch alarm for Lambda errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} ${var.function_name} - Errors"
  alarm_description = "Lambda function ${var.function_name} has errors"

  metric_name = "Errors"
  namespace   = "AWS/Lambda"
  statistic   = "Sum"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.lambda_errors_threshold
  evaluation_periods  = max(var.cloudwatch_evaluation_periods, 2)
  datapoints_to_alarm = 1
  treat_missing_data  = "notBreaching"

  alarm_actions             = local.alerts_slack_sns_topic_arns
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = var.tags
}

# CloudWatch alarm for Lambda throttles
resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} ${var.function_name} - Throttles"
  alarm_description = "Lambda function ${var.function_name} is being throttled"

  metric_name = "Throttles"
  namespace   = "AWS/Lambda"
  statistic   = "Sum"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.lambda_throttles_threshold
  evaluation_periods  = max(var.cloudwatch_evaluation_periods, 2)
  datapoints_to_alarm = 1
  treat_missing_data  = "notBreaching"

  alarm_actions             = local.alerts_slack_sns_topic_arns
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = var.tags
}

# CloudWatch alarm for Lambda duration approaching timeout
# Uses metric math to calculate percentage of timeout
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} ${var.function_name} - Duration"
  alarm_description = "Lambda function ${var.function_name} duration is approaching timeout (${var.lambda_duration_threshold_percentage}% of ${var.timeout}s)"

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.timeout * 1000 * var.lambda_duration_threshold_percentage / 100 # Convert to milliseconds
  evaluation_periods  = max(var.cloudwatch_evaluation_periods, 2)
  datapoints_to_alarm = 2
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

  tags = var.tags
}

# CloudWatch alarm for Lambda concurrent executions
resource "aws_cloudwatch_metric_alarm" "lambda_concurrent_executions" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} ${var.function_name} - Concurrent Executions"
  alarm_description = "Lambda function ${var.function_name} concurrent executions are high"

  metric_name = "ConcurrentExecutions"
  namespace   = "AWS/Lambda"
  statistic   = "Maximum"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.lambda_concurrent_executions_threshold
  evaluation_periods  = max(var.cloudwatch_evaluation_periods, 2)
  datapoints_to_alarm = 2
  treat_missing_data  = "notBreaching"

  alarm_actions             = local.alerts_slack_sns_topic_arns
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = var.tags
}

# CloudWatch alarm for Lambda error rate
# Uses metric math to calculate error rate as percentage of invocations
resource "aws_cloudwatch_metric_alarm" "lambda_error_rate" {
  count = local.cloudwatch_alarms_enabled

  alarm_name        = "${local.alarm_name_prefix} ${var.function_name} - Error Rate"
  alarm_description = "Lambda function ${var.function_name} error rate is above ${var.lambda_error_rate_threshold}%"

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.lambda_error_rate_threshold
  evaluation_periods  = max(var.cloudwatch_evaluation_periods, 2)
  datapoints_to_alarm = 2
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

  tags = var.tags
}
