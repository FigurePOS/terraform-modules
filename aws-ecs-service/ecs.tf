resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = data.aws_ecs_cluster.main.id
  task_definition = var.task_definition_arn
  propagate_tags  = "SERVICE"

  enable_execute_command = true
  force_new_deployment   = true

  desired_count                     = var.desired_count
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets         = data.aws_subnets.private.ids
    security_groups = [data.aws_security_group.cluster.id]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.service.arn
    container_name   = var.service_name
    container_port   = var.service_port
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = var.capacity_provider_strategy["ondemand"]["base"]
    weight            = var.capacity_provider_strategy["ondemand"]["weight"]
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = var.capacity_provider_strategy["spot"]["base"]
    weight            = var.capacity_provider_strategy["spot"]["weight"]
  }

  tags = {
    "Environment" = var.env
    "Service"     = var.service_name
  }
}
