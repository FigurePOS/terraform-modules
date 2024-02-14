
variable "name_prefix" {
  type = string
}
variable "ecs_cluster_name" {
  type    = string
  default = "fgr-ecs-cluster"
}
variable "ecs_service_name" {
  type = string
}
variable "low_cpu_threshold" {
  type = number
}
variable "high_cpu_threshold" {
  type = number
}
variable "min_capacity" {
  type = number
}
variable "max_capacity" {
  type = number
}
variable "metric_aggregation_type" {
  type    = string
  default = "Average"
}
