# grafana-alert-event-latency

Grafana recreation of `datadog-monitor-event-latency` for Amazon Managed Grafana.

Creates a latency (seconds) alert rule for one SQS consumer event in one env. Queries Axiom `fgr.message.consumer.duration` with OTEL `resource.name` as-is (`OrderPlaced`), not Datadog's lowercased tag.

Slack routing is **not** in this module. Platform contact points in `infrastructure/aws/monitoring` match `labels.env`:

- `development` → `#platform-warnings-dev`
- otherwise → `#platform-warnings`

## Usage (orders worker)

```hcl
module "grafana_alert_event_order_placed" {
  source = "github.com/FigurePOS/terraform-modules//grafana-alert-event-latency?ref=<tag>"

  env          = var.env
  service_name = local.service_name_worker
  event_type   = "OrderPlaced"

  latency_target = 2.0

  folder_uid    = "fgr-services"
  dashboard_uid = module.grafana_dashboard.uid
  panel_id      = module.grafana_dashboard.event_panel_ids["OrderPlaced"]
}
```

Same required inputs as the Datadog module (`env`, `service_name`, `event_type`, `latency_target`). Grafana extras: `folder_uid` (default `fgr-services`), optional `dashboard_uid` / `panel_id` for the panel link.

`interval` is seconds (default `600` = Datadog `last_10m`). `latency_percentile` stays `p95` / `p99`.

Grafana provider (`url` / `auth`) is minted by `fgr tf` / `auth-terraform-providers`.
