variable "aws_region" {
  type = string
  description = "The AWS region to create the resources in."
  default = "us-east-1"
}

variable "service_name" {
  type        = string
  description = "The name of the service the queues are for."
}

variable "queue_name" {
  type        = string
  description = "The name of the queue."
}

variable "dlq_name" {
  type        = string
  description = "The name of the dead letter queue."
  default     = null
}

variable "message_retention_seconds" {
  type        = number
  description = "The number of seconds Amazon SQS retains a message."
  default     = 1209600
}

variable "message_retention_seconds_ddl" {
  type        = number
  description = "The number of seconds Amazon SQS retains a message in the dead-letter queue."
  default     = 1209600
}

variable "redrive_policy_count" {
  type        = number
  description = "The number of times a message is delivered to the source queue before being moved to the dead-letter queue."
  default     = 3
}

variable "fifo_queue" {
  type        = bool
  description = "Whether the queue is FIFO."
  default     = false
}

variable "deduplication_scope" {
  type        = string
  description = "The scope of the deduplication for the messages in the queue."
  default     = "queue"
}

variable "fifo_throughput_limit" {
  type        = string
  description = "The throughput limit for the FIFO queue."
  default     = "perQueue"
}

variable "env" {
  type        = string
  description = "The environment the queues are for."
}

variable "datadog_tags" {
  type        = list(string)
  description = "The tags to apply to the Datadog monitor."
}

variable "datadog_identifier" {
  type        = string
  description = "The identifier for the Datadog monitor."
  default     = ""
}

variable "queue_messages_warning" {
  type        = number
  description = "The number of messages in the queue to trigger a warning."
  default     = 25
}

variable "queue_messages_critical" {
  type        = number
  description = "The number of messages in the queue to trigger a critical alert."
  default     = 100
}
