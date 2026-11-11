variable "service" {
  type = string
}
variable "service_name_readable" {
  type = string
}
variable "http_endpoints" {
  type = list(object({
    title    = string
    endpoint = string
  }))
  default = []
}
variable "events" {
  type    = list(string)
  default = []
}
variable "route_prefix" {
  type        = string
  default     = "/"
  description = "The prefix for route (now used only for ping)"
}
variable "dynamo_tables" {
  type = list(object({
    title = string
    table = string
  }))
  default = []
}
variable "queue_name" {
  type    = string
  default = ""
}
variable "dead_letter_queue_name" {
  type    = string
  default = ""
}
