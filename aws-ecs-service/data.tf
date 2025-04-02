data "aws_ecs_cluster" "main" {
  cluster_name = "fgr-ecs-cluster"
}

data "aws_lb" "main" {
  name = "fgr-ecs-load-balancer"
}

data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 443
}

data "aws_security_group" "cluster" {
  filter {
    name   = "tag:Purpose"
    values = ["cluster"]
  }
}

data "aws_service_discovery_http_namespace" "fgr-local" {
  name = "fgr-local"
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Network"
    values = ["fgr-private-services"]
  }
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Purpose"
    values = ["main"]
  }
}
