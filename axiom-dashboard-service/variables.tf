variable "api_path_prefix" {
  type        = string
  description = "Path prefix prepended to each HTTP endpoint route (e.g., \"v1\"). No leading slash."
}

variable "env" {
  type        = string
  description = "Application environment. Controls the Axiom dataset suffix (development -> -dev, production -> -prod)."

  validation {
    condition     = contains(["development", "production"], var.env)
    error_message = "env must be 'development' or 'production'."
  }
}

variable "events" {
  type        = list(string)
  default     = []
  description = "Message consumer event type names rendered as APM widgets (queried from the traces dataset)."
}

variable "http_endpoints" {
  type = list(object({
    method = string
    route  = string
  }))
  default     = []
  description = "HTTP endpoints rendered as per-endpoint APM widgets. method may be ANY for a wildcard."
}

variable "queues" {
  type = list(object({
    queue_name = string
    dlq_name   = string
    title      = string
  }))
  default     = []
  description = "SQS queues rendered as dedicated groups. dlq_name may be empty."
}

variable "service" {
  type        = string
  description = "Primary ECS service name. Used to filter SQS (via Service tag), ECS (via aws.ecs.service.name), ALB target groups (startswith targetgroup/<service>), and traces (service.name)."
}

variable "service_worker" {
  type        = string
  default     = ""
  description = "Optional worker ECS service name. When set, a second copy of the ECS/worker widgets is rendered."
}

variable "title" {
  type        = string
  description = "Dashboard title displayed in the Axiom UI."
}
