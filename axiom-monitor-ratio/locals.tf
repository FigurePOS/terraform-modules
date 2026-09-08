locals {
  dataset    = var.env == "development" ? "node-js-metrics-dev" : "node-js-metrics-prod"
  interval_m = max(floor(var.interval / 60), 1)

  eval_interval_minutes = 2
  trigger_from_n_runs   = 2
  notifier_ids          = var.notifier_ids != null ? var.notifier_ids : [data.aws_ssm_parameter.axiom_platform_warnings_notifier_id[0].value]

  where_clauses = join("\n", concat(
    ["| where `service.name` == \"${var.service_name}\""],
    [for k, v in var.filters : "| where `${k}` == \"${v}\""],
  ))

  ratio_query = <<-EOT
    (
      `${local.dataset}`:`${var.numerator_metric}`
      ${local.where_clauses}
      | map rate
      | align to 1m using avg
      | group using sum,
      `${local.dataset}`:`${var.denominator_metric}`
      ${local.where_clauses}
      | map rate
      | align to 1m using avg
      | group using sum
    )
    | compute ratio_pct using /
    | map * 100
  EOT

  summary = var.summary != null ? var.summary : var.name
}
