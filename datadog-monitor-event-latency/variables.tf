
variable "env" {
  type = string
}

variable "eval_fn" {
  type    = string
  default = "min"
}

variable "interval" {
  type    = string
  default = "last_10m"
}

variable "latency_percentile" {
  type    = string
  default = "p99"
}

variable "latency_target" {
  type        = number
  description = "Latency threshold in seconds (matches fgr.message.consumer.duration unit)."
}

variable "message" {
  type        = string
  default     = null
  description = "Datadog monitor notification message. Defaults to @slack-platform-warnings-dev in development, @slack-platform-warnings otherwise."
}

variable "notify_on_missing_data" {
  type    = bool
  default = false
}

variable "resource_name" {
  type        = string
  description = "SQS event type (traceSqsMessage opts.resource), e.g. OrderPlaced. Must match fgr.message.consumer.* metric resource.name."
}

variable "service_name" {
  type = string
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "Additional Datadog monitor tags. An env:<environment> tag is always included from var.env."
}
