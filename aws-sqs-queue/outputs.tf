output "normal_queue_name" {
  value = aws_sqs_queue.normal.name
}

output "normal_queue_arn" {
  value = aws_sqs_queue.normal.arn
}

output "normal_queue_url" {
  value = aws_sqs_queue.normal.url
}

output "ddl_queue_name" {
  value = aws_sqs_queue.ddl.name
}

output "ddl_queue_arn" {
  value = aws_sqs_queue.ddl.arn
}

output "ddl_queue_url" {
  value = aws_sqs_queue.ddl.url
}
