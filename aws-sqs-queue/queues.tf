resource "aws_sqs_queue" "queue" {
  name                      = "${var.service_name}${var.fifo_queue ? ".fifo" : ""}"
  message_retention_seconds = var.message_retention_seconds
  fifo_queue                = var.fifo_queue

  deduplication_scope   = var.deduplication_scope
  fifo_throughput_limit = var.fifo_throughput_limit

  kms_master_key_id                 = data.aws_kms_key.sqs_encryption_key.id
  kms_data_key_reuse_period_seconds = 300

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.redrive_policy_count
  })
}

resource "aws_sqs_queue" "dlq" {
  name                      = "${var.service_name}_dlq${var.fifo_queue ? ".fifo" : ""}"
  message_retention_seconds = var.message_retention_seconds_ddl
  fifo_queue                = var.fifo_queue

  kms_master_key_id                 = data.aws_kms_key.sqs_encryption_key.id
  kms_data_key_reuse_period_seconds = 300
}
