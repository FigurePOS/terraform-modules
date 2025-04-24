resource "aws_xray_group" "service" {
  group_name        = var.service_name
  filter_expression = "service(\"${var.service_name}\")"
} 

resource "aws_xray_sampling_rule" "ping_requests" {
  rule_name      = "${var.service_name}-ping"
  priority       = 10
  reservoir_size = 0
  fixed_rate     = 0
  url_path       = "*${var.ping_path}*"
  host           = "*"
  http_method    = "*"
  service_name   = var.service_name
  service_type   = "*"
  resource_arn   = "*"
  version        = 1
}

resource "aws_xray_sampling_rule" "service" {
  rule_name      = var.service_name
  priority       = 1000
  reservoir_size = 1
  fixed_rate     = var.xray_sampling_rate
  url_path       = "*"
  host           = "*"
  http_method    = "*"
  service_name   = var.service_name
  service_type   = "*"
  resource_arn   = "*"
  version        = 1
}
