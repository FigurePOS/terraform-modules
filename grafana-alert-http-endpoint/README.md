# grafana-alert-http-endpoint

Grafana recreation of `datadog-monitor-http-endpoint` for Amazon Managed Grafana.

Creates error-rate (%) and latency (seconds) alert rules for one HTTP route in one env. Queries Axiom (`fgr.http.server.request.*`) with OTEL `resource.name` (`POST /payments/payment/:id`), not Datadog tags (`post_/...`).

Slack routing is **not** in this module. Platform contact points in `infrastructure/aws/monitoring` match `labels.env`:

- `development` → `#platform-warnings-dev`
- otherwise → `#platform-warnings`

## Usage (payments)

```hcl
module "grafana_alert_endpoint_post_payment" {
  source = "github.com/FigurePOS/terraform-modules//grafana-alert-http-endpoint?ref=<tag>"

  env             = var.env
  service_name    = var.service_name
  api_path_prefix = local.api_path_prefix

  method            = "POST"
  route             = "/payment/:id"
  error_rate_target = 1
  latency_target    = 0.5

  folder_uid    = "fgr-services"
  dashboard_uid = module.grafana_dashboard.uid
  panel_id      = module.grafana_dashboard.http_panel_ids["POST /payment/:id"]
}
```

Same required inputs as the Datadog module (`env`, `service_name`, `api_path_prefix`, `method`, `route`, `error_rate_target`, `latency_target`). Grafana extras: `folder_uid` (default `fgr-services`), optional `dashboard_uid` / `panel_id` for the panel link.

`interval` is seconds (default `600` = Datadog `last_10m`). `latency_percentile` stays `p95` / `p99`.

Grafana provider (`url` / `auth`) is minted by `fgr tf` / `auth-terraform-providers`.
