
variable "env" {
  type = string
}

variable "service_name" {
  type = string
}

variable "queue_name" {
  type = string
}

variable "dead_letter_queue_name" {
  type = string
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "identifier" {
  type    = string
  default = ""
}

variable "message_slack" {
  type    = string
  default = "@slack-figure-alerts"
}

variable "message_opsgenie" {
  type    = string
  default = "{{#is_alert}}@opsgenie{{/is_alert}} {{#is_recovery}}@opsgenie{{/is_recovery}}"
}

variable "message" {
  type    = string
  default = "@slack-figure-alerts {{#is_alert}}@opsgenie{{/is_alert}} {{#is_recovery}}@opsgenie{{/is_recovery}}"
}

variable "queue_messages_warning" {
  type    = number
  default = 25
}

variable "queue_messages_critical" {
  type    = number
  default = 100
}

variable "queue_rollup" {
  type = number
  default = 300
}

variable "dead_letter_queue_messages_critical" {
  type    = number
  default = 50
}

variable "dead_letter_queue_renotify_interval" {
  type    = number
  default = 24 * 60
}

variable "dead_letter_queue_increased_messages_critical" {
  type    = number
  default = 20
}

variable "dead_letter_queue_increased_renotify_interval" {
  type    = number
  default = 24 * 60
}

variable "dead_letter_queue_rollup" {
  type = number
  default = 300
}
