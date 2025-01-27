resource "aws_alb_target_group" "service" {
  # checkov:skip=CKV_AWS_378:Usage of HTTP instead of HTTPS. TODO: Check this.
  name                 = substr(var.service_name, 0, 32)
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.main.id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
    matcher             = 200
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
  }

  tags = {
    "Environment" = var.env
    "Service"     = var.service_name
  }
}

resource "aws_alb_listener_rule" "service" {
  listener_arn = data.aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.service.arn
  }

  condition {
    host_header {
      values = local.lb_listener_rule_host_header
    }
  }

  condition {
    path_pattern {
      values = var.lb_listener_rule_path_pattern
    }
  }

  lifecycle {
    ignore_changes = [
      priority
    ]
  }

  tags = {
    "Environment" = var.env
    "Service"     = var.service_name
  }
}


output "lb_listener_arn" {
  value = data.aws_lb_listener.https.arn
}

output "lb_target_group_arn" {
  value = aws_alb_target_group.service.arn
}
