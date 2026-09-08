data "aws_ssm_parameter" "axiom_platform_warnings_notifier_id" {
  count = var.notifier_ids == null ? 1 : 0
  name  = "/axiom/platform_warnings_notifier_id"
}
