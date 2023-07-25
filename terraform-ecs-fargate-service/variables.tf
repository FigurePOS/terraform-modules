
variable "env" {}
variable "ecs_cluster_id" {}
variable "vpc_id" {}
variable "service_port" {}
variable "service_name" {}
variable "task_execution_role_arn" {}
variable "task_role_arn" {}
variable "load_balancer_listener_arn" {}
variable "load_balancer_listener_host_header" {}
variable "load_balancer_listener_host_header_2" {}
variable "load_balancer_path_pattern" {}
variable "load_balancer_health_check_path" {}
variable "ecr_repository_url" {}
variable "desired_count" { default = 1 }
variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
