output "lambda_function_arn" {
  description = "The ARN of the Lambda Function"
  value       = aws_lambda_function.this.arn
}

output "lambda_function_invoke_arn" {
  description = "The Invoke ARN of the Lambda Function"
  value       = aws_lambda_function.this.invoke_arn
}

output "lambda_function_version" {
  description = "The version of the Lambda Function"
  value       = aws_lambda_function.this.version
}

output "lambda_function_last_modified" {
  description = "The date Lambda Function was last modified"
  value       = aws_lambda_function.this.last_modified
}

output "lambda_role_arn" {
  description = "The ARN of the IAM role created for the Lambda Function"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_name" {
  description = "The name of the IAM role created for the Lambda Function"
  value       = aws_iam_role.lambda_role.name
}

output "cloudwatch_event_rule_arn" {
  description = "The ARN of the CloudWatch Event Rule (if scheduling is enabled)"
  value       = local.scheduling_enabled ? aws_cloudwatch_event_rule.lambda_schedule[0].arn : null
}

output "cloudwatch_event_rule_name" {
  description = "The name of the CloudWatch Event Rule (if scheduling is enabled)"
  value       = local.scheduling_enabled ? aws_cloudwatch_event_rule.lambda_schedule[0].name : null
}
