locals {
  count          = var.env == "production" ? 1 : 0
  dataset_suffix = var.env == "production" ? "prod" : "dev"
  dataset        = "node-js-traces-${local.dataset_suffix}"

  # APL filter shared between both monitors.
  # 'name' is the OTEL span name set by the Express instrumentation (e.g. "GET /orders/:id").
  # 'fgr_service_name' is the normalized service identifier virtual field on the traces dataset.
  base_filter = <<-APL
    ['${local.dataset}']
    | where ['fgr_service_name'] == "${var.service_name}"
    | where ['name'] == "${var.span_name}"
  APL
}

resource "axiom_monitor" "error_rate" {
  count = local.count

  name        = "${var.service_name} – APM - ${var.span_name_readable} – Error rate"
  description = "Fires when the error rate for ${var.span_name_readable} exceeds ${var.error_rate_target}% over ${var.range_minutes} minutes."
  type        = "Threshold"

  # Calculates the percentage of spans with OTEL status code ERROR (2).
  # duration is not relevant here; status.code == 2 means STATUS_CODE_ERROR per OTEL spec.
  apl_query = <<-APL
    ${trimspace(local.base_filter)}
    | summarize
        total  = count(),
        errors = countif(['status']['code'] == 2)
      by bin_auto(_time)
    | extend error_rate = iff(total > 0, todouble(errors) * 100.0 / todouble(total), 0.0)
    | project _time, error_rate
  APL

  interval_minutes = var.interval_minutes
  range_minutes    = var.range_minutes
  operator         = "Above"
  threshold        = var.error_rate_target

  notifier_ids = var.notifier_ids
}

resource "axiom_monitor" "latency" {
  count = local.count

  name        = "${var.service_name} – APM - ${var.span_name_readable} – Latency (p${var.latency_percentile})"
  description = "Fires when p${var.latency_percentile} latency for ${var.span_name_readable} exceeds ${var.latency_target} ms over ${var.range_minutes} minutes."
  type        = "Threshold"

  # duration is stored in nanoseconds by the OTEL collector; dividing by 1e6 converts to milliseconds.
  apl_query = <<-APL
    ${trimspace(local.base_filter)}
    | summarize latency_ms = percentile(duration / 1000000.0, ${var.latency_percentile})
        by bin_auto(_time)
    | project _time, latency_ms
  APL

  interval_minutes = var.interval_minutes
  range_minutes    = var.range_minutes
  operator         = "Above"
  threshold        = var.latency_target

  alert_on_no_data = var.notify_on_missing_data

  notifier_ids = var.notifier_ids
}
