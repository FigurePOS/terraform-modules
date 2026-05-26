data "aws_ssm_parameter" "axiom_platform_warnings_notifier_id" {
  name = "/axiom/platform_warnings_notifier_id"
}

data "aws_ssm_parameter" "axiom_rootly_notifier_id" {
  name = "/axiom/rootly_notifier_id"
}
