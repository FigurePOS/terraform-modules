# axiom-monitor-http-endpoint

Axiom-native twin of `grafana-alert-http-endpoint`. Same MPL on `fgr.http.server.request.*`, same call-site inputs (minus Grafana folder/panel fields).

Creates error-rate (%) and latency (seconds) threshold monitors for one HTTP route in one env. OTEL `resource.name` is `POST /payments/payment/:id`, not Datadog tags.

Slack is the env-scoped SSM notifier `/axiom/platform_warnings_notifier_id` (`#platform-warnings` / `#platform-warnings-dev`).

## Usage (payments)

```hcl
module "axiom_monitor_endpoint_post_payment" {
  source = "github.com/FigurePOS/terraform-modules//axiom-monitor-http-endpoint?ref=<tag>"

  env             = var.env
  service_name    = var.service_name
  api_path_prefix = local.api_path_prefix

  method            = "POST"
  route             = "/payment/:id"
  error_rate_target = 1
  latency_target    = 0.5
}
```

Needs the Axiom provider in the service root (`api_token`). Eval every 2m (`interval_minutes`) over a 15m lookback (`range_minutes`, default 15). Latency is a clock-aligned average of 1m p95s over `range_minutes - 5` (10m at default; Datadog `avg(last_10m):p95`). Fires after 2 consecutive evals.
