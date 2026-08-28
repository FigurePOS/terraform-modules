variable "cluster_name" {
  type        = string
  default     = "fgr-ecs-cluster"
  description = "ECS cluster name for CloudWatch AWS/ECS dimensions."
}

variable "dashboard_uid" {
  type        = string
  default     = null
  description = "Stable Grafana dashboard UID. Defaults to var.service (e.g. fgr-service-payments)."
}

variable "dynamodb_tables" {
  type = list(object({
    table_name = string
    title      = string
  }))
  default     = []
  description = "DynamoDB tables with table name and readable title for the group."
}

variable "events" {
  type        = list(string)
  default     = []
  description = "SQS consumer event names. Filters use OTEL resource.name (the event name as-is, not Datadog lowercased tags)."
}

variable "http_endpoint_prefix" {
  type        = string
  description = "ALB mount prefix without slashes (e.g. payments). Combined with http_endpoints.route for OTEL resource.name (POST /payments/payment/:id)."
}

variable "http_endpoints" {
  type = list(object({
    method = string
    route  = string
  }))
  default     = []
  description = "HTTP endpoints with method (GET, POST, ANY, …) and route (e.g. /payment/:id). Metric filters use OTEL resource.name (POST /{http_endpoint_prefix}{route}), not Datadog get_/… tags."
}

variable "queues" {
  type = list(object({
    queue_name = string
    dlq_name   = string
    title      = string
  }))
  default     = []
  description = "SQS queues with queue name, DLQ name (empty string skips the DLQ stat), and readable group title."
}

variable "service" {
  type        = string
  description = "ECS service name (OTEL service.name / CloudWatch ServiceName)."
}

variable "service_worker" {
  type        = string
  default     = ""
  description = "Optional worker ECS service name. When set, adds an Application – Worker row (CPU/mem/tasks/event-loop, no ALB)."
}

variable "tags" {
  type        = list(string)
  default     = ["service"]
  description = "Grafana dashboard tags."
}

variable "title" {
  type        = string
  description = "Dashboard title (e.g. Payments Service)."
}
