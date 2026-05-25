locals {
  traces_dataset = "node-js-traces-${var.env == "production" ? "prod" : "dev"}"
  duration_ms    = "toreal(trim_end(\"ms\", tostring(duration)))"

  trace_filter = join(" ", [
    "['${local.traces_dataset}']",
    "| where ['fgr_service_name'] == \"${var.service_name}\" and kind == \"server\"",
    "| where isnotnull(['attributes.custom']['http.target'])",
    "| where ['attributes.custom']['resource.name'] == \"${var.endpoint}\"",
  ])

  error_rate_apl_query = "${local.trace_filter} | summarize 100.0 * countif(error == true) / count()"
  latency_apl_query    = "${local.trace_filter} | summarize percentile(${local.duration_ms}, ${var.latency_percentile})"
}
