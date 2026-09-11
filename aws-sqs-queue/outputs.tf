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

output "grafana_dlq_messages_rule_group_id" {
  description = "Grafana rule group ID for DLQ message count reminders."
  value       = grafana_rule_group.dlq_messages_count.id
}
