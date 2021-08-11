
variable "env" {
  type = string
}

variable "service_name_readable" {
  type = string
}

variable "queue_name" {
  type = string
}

variable "dead_letter_queue_name" {
  type = string
}

variable "tags" {
  type = list(string)
  default = []
}

variable "message" {
  type = string
  default = "@slack-figure-alerts {{#is_alert}}@opsgenie{{/is_alert}} {{#is_recovery}}@opsgenie{{/is_recovery}}"
}

variable "queue_messages_warning" {
  type = number
  default = 25
}

variable "queue_messages_critical" {
  type = number
  default = 100
}

variable "dead_letter_queue_messages_warning" {
  type = number
  default = 0
}

variable "dead_letter_queue_messages_critical" {
  type = number
  default = 50
}

variable "dead_letter_queue_renotify_interval" {
  type = number
  default = 3600 * 24
}
