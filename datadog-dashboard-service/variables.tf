variable "api_path_prefix" {
  type = string
}

variable "events" {
  type    = list(string)
  default = []
}

variable "http_endpoints" {
  type = list(object({
    method = string
    route  = string
  }))
  default     = []
  description = "List of HTTP endpoints with method (GET, POST, DELETE, etc.) and route (e.g., /account, /pricing/:id)"
}

variable "queues" {
  type = list(object({
    queue_name = string
    dlq_name   = string
    title      = string
  }))
  default     = []
  description = "List of SQS queues with queue name, DLQ name, and readable name (title for the group)"
}

variable "service" {
  type = string
}
variable "service_worker" {
  type    = string
  default = ""
}

variable "title" {
  type = string
}
