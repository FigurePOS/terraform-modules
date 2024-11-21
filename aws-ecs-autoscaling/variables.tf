variable "ecs_cluster_name" {
  type    = string
  default = "fgr-ecs-cluster"
}

variable "ecs_service_name" {
  type = string
}

variable "cpu_target_value" {
  type        = number
  description = "The target average CPU utilization percentage for scaling."
  default     = 70
}

variable "sqs_messages_target_value" {
  type        = number
  description = "The target number of messages in the SQS queue for scaling."
  default     = 100
}

variable "sqs_queue_name" {
  type        = string
  description = "The name of the SQS queue to monitor for scaling."
}

variable "min_capacity" {
  type = number
}

variable "max_capacity" {
  type = number
}

variable "scale_in_cooldown" {
  type        = number
  description = "The amount of time, in seconds, after a scale in activity completes before another scale in activity can start."
  default     = 150
}

variable "scale_out_cooldown" {
  type        = number
  description = "The amount of time, in seconds, after a scale out activity completes before another scale out activity can start."
  default     = 300
}


locals {
  resource_id = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
}
