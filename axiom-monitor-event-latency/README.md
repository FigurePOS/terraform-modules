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

Needs the Axiom provider in the service root (`api_token`). Eval every 2m over a 10m lookback (Datadog `avg(last_10m)`). Query is a window average, not “any 1m point”. Fires after 2 consecutive evals.
