# axiom-monitor-event-latency

Axiom-native twin of `grafana-alert-event-latency`. Same MPL on `fgr.message.consumer.duration`.

Creates a latency (seconds) threshold monitor for one SQS consumer event in one env. OTEL `resource.name` is the event name as-is (`OrderPlaced`).

Slack is `/axiom/platform_warnings_notifier_id`.

## Usage (orders worker)

```hcl
module "axiom_monitor_event_order_placed" {
  source = "github.com/FigurePOS/terraform-modules//axiom-monitor-event-latency?ref=<tag>"

  env          = var.env
  service_name = local.service_name_worker
  event_type   = "OrderPlaced"

  latency_target = 2.0
}
```

Needs the Axiom provider in the service root (`api_token`). Eval every 2m (`interval_minutes`) over a 15m lookback (`range_minutes`, default 15). Latency is a clock-aligned average of 1m p95s over `range_minutes - 5` (10m at default; Datadog `avg(last_10m):p95`). Fires after 2 consecutive evals.
