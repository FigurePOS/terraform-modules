locals {
  dataset       = var.env == "development" ? "node-js-metrics-dev" : "node-js-metrics-prod"
  range_minutes = var.range_minutes != null ? var.range_minutes : (var.interval != null ? var.interval / 60 : 15)
  # Align is clock-aligned, not sliding: at 10:07 the 10:00–10:10 avg is still open, so
  # Axiom needs 09:50–10:00 still inside the lookback. Buffer keeps range wider than align.
  align_buffer_minutes = 5
  align_minutes        = local.range_minutes - local.align_buffer_minutes
  percentile           = tonumber(trimprefix(var.latency_percentile, "p")) / 100

  trigger_from_n_runs = 2
  notifier_ids        = var.notifier_ids != null ? var.notifier_ids : [data.aws_ssm_parameter.axiom_platform_warnings_notifier_id[0].value]

  latency_summary = "${var.latency_percentile} latency for ${var.event_type} is over ${var.latency_target}s (${var.env})"

  # avg of 1m p95s over a complete (range-5)m bucket. Clock-aligned; Datadog avg(last_10m):p95 at default 15m range.
  latency_query = <<-EOT
    `${local.dataset}`:`fgr.message.consumer.duration`
    | where `service.name` == "${var.service_name}"
    | where `resource.name` == "${var.event_type}"
    | bucket to 1m using interpolate_delta_histogram(${local.percentile})
    | align to ${local.align_minutes}m using avg
  EOT
}
