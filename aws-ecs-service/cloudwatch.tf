resource "aws_cloudwatch_log_group" "log_group" {
  # checkov:skip=CKV_AWS_158:Log group is not encrypted. TODO
  # checkov:skip=CKV_AWS_338:Ensure CloudWatch log groups retains logs for at least 1 year.
  name              = "/figure/container/${var.service_name}"
  retention_in_days = 3
}

resource "aws_lambda_permission" "axiom_log_forwarder" {
  statement_id  = "AllowExecutionFromCloudWatchLogs-${replace(aws_cloudwatch_log_group.log_group.name, "/", "-")}"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.axiom_log_forwarder.function_name
  principal     = "logs.${data.aws_region.current.region}.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.log_group.arn}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "axiom" {
  name            = aws_cloudwatch_log_group.log_group.name
  log_group_name  = aws_cloudwatch_log_group.log_group.name
  filter_pattern  = ""
  destination_arn = data.aws_lambda_function.axiom_log_forwarder.arn

  depends_on = [aws_lambda_permission.axiom_log_forwarder]
}
