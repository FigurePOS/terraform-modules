locals {
  dataset    = var.env == "development" ? "node-js-metrics-dev" : "node-js-metrics-prod"
  interval_m = max(floor(var.interval / 60), 1)
  percentile = tonumber(trimprefix(var.latency_percentile, "p")) / 100

  eval_interval_minutes = 2
  trigger_from_n_runs   = 2
  notifier_ids          = var.notifier_ids != null ? var.notifier_ids : [data.aws_ssm_parameter.axiom_platform_warnings_notifier_id[0].value]

  latency_summary = "${var.latency_percentile} latency for ${var.event_type} is over ${var.latency_target}s (${var.env})"

  # Omit `to <window>` so the histogram is over the full monitor range (one value).
  # `bucket to 1m` + range_minutes=10 is rejected by Axiom: "range too short for the bin size".
  latency_query = <<-EOT
    `${local.dataset}`:`fgr.message.consumer.duration`
    | where `service.name` == "${var.service_name}"
    | where `resource.name` == "${var.event_type}"
    | bucket using interpolate_delta_histogram(${local.percentile})
  EOT
}
