# axiom-monitor-ratio

Axiom-native twin of `grafana-alert-ratio`. Same MPL for `100 * numerator / denominator`.

Use for business counter ratios that are not HTTP server or SQS consumer metrics — e.g. delivery provider estimation/request error rates.

Always filters `service.name`. Extra attribute filters go in `filters` (applied to both sides).

Slack is `/axiom/platform_warnings_notifier_id`.

## Usage (delivery provider error rate)

```hcl
module "axiom_monitor_delivery_provider_error_rate" {
  source   = "github.com/FigurePOS/terraform-modules//axiom-monitor-ratio?ref=<tag>"
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
}
```

Needs the Axiom provider in the service root (`api_token`). Eval every 2m over a 10m lookback (Datadog `avg(last_10m)`). Query is a window average, not “any 1m point”. Fires after 2 consecutive evals.
