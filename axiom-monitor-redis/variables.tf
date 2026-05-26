variable "cpu_align_minutes" {
  type        = number
  default     = 5
  description = "MPL align window for CPU utilization, in minutes"
}

variable "cpu_interval_minutes" {
  type        = number
  default     = 5
  description = "How often the CPU monitor runs, in minutes"
}

variable "cpu_range_minutes" {
  type        = number
  default     = 5
  description = "CPU monitor query lookback window in minutes"
}

variable "cpu_threshold" {
  type        = number
  default     = 90
  description = "CPU utilization threshold in percent"
}

variable "env" {
  type = string
}

variable "memory_align_minutes" {
  type        = number
  default     = 60
  description = "MPL align window for memory usage, in minutes"
}

variable "memory_interval_minutes" {
  type        = number
  default     = 5
  description = "How often the memory monitor runs, in minutes"
}

variable "memory_range_minutes" {
  type        = number
  default     = 60
  description = "Memory monitor query lookback window in minutes"
}

variable "memory_threshold" {
  type        = number
  default     = 80
  description = "Database memory usage threshold in percent"
}

variable "message" {
  type    = string
  default = "Platform warnings Slack channel"
}

variable "notify_on_missing_data" {
  type    = bool
  default = false
}

variable "service_name" {
  type = string
}
