# grafana-alert-ratio

Grafana alert for `100 * numerator / denominator` over an eval window (Axiom MPL).

Use for business counter ratios that are not HTTP server or SQS consumer metrics — e.g. delivery provider estimation/request error rates. Replaces ad-hoc `datadog-monitor-metric` ratio queries for those cases.

Always filters `service.name`. Extra attribute filters go in `filters` (applied to both sides).

Slack routing is **not** in this module. Platform contact points in `infrastructure/aws/monitoring` match `labels.env`.

## Usage (delivery provider error rate)

```hcl
module "grafana_alert_delivery_provider_error_rate" {
  source   = "github.com/FigurePOS/terraform-modules//grafana-alert-ratio?ref=<tag>"
  for_each = local.delivery_provider_error_rate_monitors

  env          = var.env
  service_name = var.service_name

  name               = "${var.service_name} – ${each.value.display_name} ${each.value.operation.subject} – Error rate (${var.env})"
  summary            = "Error rate of ${each.value.operation.subject} for ${each.value.display_name} is over 10% (${var.env})"
  numerator_metric   = each.value.operation.failed_metric
  denominator_metric = each.value.operation.requested_metric
  filters = {
    resource = each.value.resource
  }
  threshold = 10
  interval  = 300

  folder_uid = var.service_name
  labels     = local.grafana_labels
}
```

`interval` default is `300` (Datadog `last_5m`). Grafana provider (`url` / `auth`) is minted by `fgr tf` / `auth-terraform-providers`.
