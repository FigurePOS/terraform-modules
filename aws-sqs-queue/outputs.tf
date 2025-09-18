output "cloudwatch_alarm_dlq_messages_critical_arn" {
  description = "ARN of the CloudWatch alarm for DLQ message count critical"
  value       = length(aws_cloudwatch_metric_alarm.dlq_messages_critical) > 0 ? aws_cloudwatch_metric_alarm.dlq_messages_critical[0].arn : null
}

output "cloudwatch_alarm_dlq_messages_increasing_arn" {
  description = "ARN of the CloudWatch alarm for DLQ increasing messages"
  value       = length(aws_cloudwatch_metric_alarm.dlq_messages_increasing) > 0 ? aws_cloudwatch_metric_alarm.dlq_messages_increasing[0].arn : null
}

output "cloudwatch_alarm_sqs_messages_critical_arn" {
  description = "ARN of the CloudWatch alarm for SQS message count critical"
  value       = length(aws_cloudwatch_metric_alarm.sqs_messages_critical) > 0 ? aws_cloudwatch_metric_alarm.sqs_messages_critical[0].arn : null
}

output "cloudwatch_alarm_sqs_messages_warning_arn" {
  description = "ARN of the CloudWatch alarm for SQS message count warning"
  value       = length(aws_cloudwatch_metric_alarm.sqs_messages_warning) > 0 ? aws_cloudwatch_metric_alarm.sqs_messages_warning[0].arn : null
}

output "dlq_arn" {
  value = aws_sqs_queue.dlq.arn
}

output "dlq_name" {
  value = aws_sqs_queue.dlq.name
}

output "dlq_url" {
  value = aws_sqs_queue.dlq.url
}

output "queue_arn" {
  value = aws_sqs_queue.queue.arn
}

output "queue_name" {
  value = aws_sqs_queue.queue.name
}

output "queue_url" {
  value = aws_sqs_queue.queue.url
}
