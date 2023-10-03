
variable "env" {
  type = string
}

variable "service_name" {
  type = string
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "message" {
  type    = string
  default = "@slack-figure-alerts {{#is_alert}}@opsgenie{{/is_alert}} {{#is_recovery}}@opsgenie{{/is_recovery}}"
}

variable "cpu_warning" {
  type    = number
  default = 80
}

variable "cpu_critical" {
  type    = number
  default = 95
}

variable "memory_warning" {
  type    = number
  default = 80
}

variable "memory_critical" {
  type    = number
  default = 95
}

variable "interval" {
  type    = string
  default = "last_10m"
}
