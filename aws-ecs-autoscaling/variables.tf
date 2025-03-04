variable "ecs_service_name" {
  type = string
}

variable "cpu_target_value" {
  type        = number
  description = "The target average CPU utilization percentage for scaling."
  default     = 75
}

variable "memory_target_value" {
  type        = number
  description = "The target average memory utilization percentage for scaling."
  default     = null
}

variable "sqs_queue_params" {
  type = object({
    queue_name            = string
    messages_target_value = string
  })
  description = "SQS queue parameters for scaling."
  default     = null
}

variable "min_capacity" {
  type = number
}

variable "max_capacity" {
  type = number
}

variable "scale_in_cooldown" {
  type        = number
  description = "(Scale down) The amount of time, in seconds, after a scale in activity completes before another scale in activity can start."
  default     = 300
}

variable "scale_out_cooldown" {
  type        = number
  description = "(Scale up) The amount of time, in seconds, after a scale out activity completes before another scale out activity can start."
  default     = 150
}

locals {
  ecs_cluster_name = "fgr-ecs-cluster"
  resource_id      = "service/${local.ecs_cluster_name}/${var.ecs_service_name}"
}
