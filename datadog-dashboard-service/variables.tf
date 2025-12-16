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
  default = []
  description = "List of HTTP endpoints with method (GET, POST, DELETE, etc.) and route (e.g., /account, /pricing/:id)"
}

variable "queue_dlq_name" {
  type    = string
  default = ""
}

variable "queue_name" {
  type    = string
  default = ""
}

variable "service" {
  type = string
}

variable "service_name_readable" {
  type = string
}

variable "service_worker" {
  type    = string
  default = ""
}
