
variable "env" {
  type = string
}

variable "event_type" {
  type        = string
  description = "SQS event type passed to traceSqsMessage opts.resource (e.g. ProductUpdated). Must match fgr.message.consumer.* resource.name."
}

variable "interval" {
  type    = string
  default = "last_10m"
}

variable "latency_eval_fn" {
  type        = string
  default     = "avg"
  description = "Time aggregation for the latency monitor (e.g. avg, max, min). Use max to alert on worst p99 in the window."
}

variable "latency_percentile" {
  type    = string
  default = "p95"
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

variable "service_name" {
  type = string
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "Additional Datadog monitor tags. An env:<environment> tag is always included from var.env."
}
