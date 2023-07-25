
variable "namespace" {}
variable "ecs_cluster_name" {}
variable "ecs_service_name" {}
variable "low_cpu_threshold" {}
variable "high_cpu_threshold" {}
variable "min_capacity" {}
variable "max_capacity" {}

variable "metric_aggregation_type" {
  default = "Maximum"
}
