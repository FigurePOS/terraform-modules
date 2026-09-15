# axiom-monitor-http-client

Axiom-native twin of `grafana-alert-http-client`. Same MPL on `fgr.http.client.request`.

Creates error-rate (%) and latency (seconds) monitors for one remote client in one env. Always filters OTEL `service.name`. Pass remote identity via `filters` — attribute `service` is the gateway/client id, not `service.name`.

Latency: metric is recorded in **ms**; the query divides by 1000 so `latency_target` is in **seconds**.

Slack is `/axiom/platform_warnings_notifier_id`.

## Usage (payments gateways)

```hcl
locals {
  payment_gateway_clients = var.env == "production" ? {
    CardPointe  = "CardPointe"
    TSYS        = "TSYS"
    Converge    = "Converge"
    SeamlessPay = "SeamlessPay"
  } : {}
}

module "axiom_monitor_payment_gateway" {
  source   = "github.com/FigurePOS/terraform-modules//axiom-monitor-http-client?ref=<tag>"
  for_each = local.payment_gateway_clients

  env          = var.env
  service_name = var.service_name

  name = "${each.value} gateway"
  filters = {
    type    = "payment_gateway"
    service = each.key
  }

  error_rate_target = 1
  latency_target    = 5
}
```

Needs the Axiom provider in the service root (`api_token`). Eval every 2m over a 15m lookback (`interval` default `900`; min 15m because Axiom rejects `bucket to 1m` below that). Latency is `avg` of 1m p95s (Datadog `avg(last_Xm):p95`), not p95 of the whole window. Fires after 2 consecutive evals.
