# CloudWatch Event Rule for scheduled Lambda execution (optional)
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  count               = local.scheduling_enabled ? 1 : 0
  name                = var.function_name
  description         = var.schedule_description != "" ? var.schedule_description : "Schedule for ${var.function_name}"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  count     = local.scheduling_enabled ? 1 : 0
  rule      = aws_cloudwatch_event_rule.lambda_schedule[0].name
  target_id = "${var.function_name}-target"
  arn       = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  count         = local.scheduling_enabled ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule[0].arn
}
