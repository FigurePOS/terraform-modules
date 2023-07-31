
resource "aws_ecs_task_definition" "task_definition_api" {
  family = var.service_name
  execution_role_arn = var.task_execution_role_arn
  task_role_arn = var.task_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  container_definitions = jsonencode([
    {
      "name": var.service_name,
      "image": "${var.ecr_repository_url}:latest",
      "portMappings": [
            {
                "containerPort": 4000
            }
        ],
        "readonlyRootFilesystem": true,
    },
    { #checkov:skip=CKV_AWS_336: Ensure ECS containers are limited to read-only access to root filesystems - not possible for datadog-agent
      "name": "datadog-agent",
      "image": "datadog/agent:latest"
    }
  ])

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_ecs_service" "ecs_service" {
  name = var.service_name
  cluster = var.ecs_cluster_id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.task_definition_api.arn
  propagate_tags = "SERVICE"

  desired_count = var.desired_count
  health_check_grace_period_seconds = 30

  network_configuration {
    subnets = var.subnet_ids
    security_groups = var.security_group_ids
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.ecs_service_target_group.arn
    container_name = var.service_name
    container_port = var.service_port
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}

resource "aws_alb_target_group" "ecs_service_target_group" {
  name = substr(var.service_name, 0, 32)
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"
  deregistration_delay = 30

  health_check {
    healthy_threshold = var.load_balancer_health_check_healthy_threshold
    unhealthy_threshold = var.load_balancer_health_check_unhealthy_threshold
    interval = 30
    matcher = 200
    path = var.load_balancer_health_check_path
    port = "traffic-port"
    protocol = "HTTP"
    timeout = 5
  }
}

resource "aws_alb_listener_rule" "ecs_alb_listener_rule" {
  listener_arn = var.load_balancer_listener_arn

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.ecs_service_target_group.arn
  }

  condition {
    host_header {
      values = var.load_balancer_listener_rule_host_headers
    }
  }

  condition {
    path_pattern {
      values = var.load_balancer_listener_rule_path_patterns
    }
  }

  lifecycle {
    ignore_changes = [
      priority
    ]
  }
}
