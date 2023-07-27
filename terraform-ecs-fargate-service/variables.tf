
variable "env" {
    type = string
}
variable "ecs_cluster_id" {
    type = string
}
variable "vpc_id" {
    type = string
}
variable "service_port" {
    type = number
}
variable "service_name" {
    type = string
}
variable "task_execution_role_arn" {
    type = string
}
variable "task_role_arn" {
    type = string
}
variable "load_balancer_listener_arn" {
    type = string
}
variable "load_balancer_listener_rule_host_headers" {
    type = list(string)
}
variable "load_balancer_listener_rule_path_patterns" {
    type = list(string)
}
variable "load_balancer_health_check_path" {
    type = string
}
variable "ecr_repository_url" {
    type = string
}
variable "desired_count" {
    type = number
    default = 1 
}
variable "subnet_ids" { 
    type = list(string) 
}
variable "security_group_ids" { 
    type = list(string) 
}
