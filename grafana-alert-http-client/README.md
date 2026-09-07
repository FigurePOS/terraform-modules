# grafana-alert-http-client

Grafana alerts for outbound HTTP client metrics (`fgr.http.client.request`).

Creates **error-rate (%)** and **latency (seconds)** rules for one remote client in one env. Queries the histogram emitted by `sendTimerMetric("fgr.http.client.request", …)` with attributes such as `type`, `service` (remote id), and `http_status_class`.

Always filters OTEL `service.name` (the calling service). Pass remote identity via `filters` — note attribute `service` is the gateway/client id, not `service.name`.

Latency: metric is recorded in **ms**; the query divides by 1000 so `latency_target` is in **seconds** (same as `grafana-alert-http-endpoint`). Datadog’s 5000ms threshold → `latency_target = 5`.

Slack routing is **not** in this module. Platform contact points match `labels.env`.

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

module "grafana_alert_payment_gateway" {
  source   = "github.com/FigurePOS/terraform-modules//grafana-alert-http-client?ref=<tag>"
  for_each = local.payment_gateway_clients

  env          = var.env
  service_name = var.service_name

  name = "${each.value} gateway"
  filters = {
    type    = "payment_gateway"
    service = each.key # OTEL attribute value (PaymentGateway enum), not Datadog's lowercased tag
  }

  error_rate_target = 1
  latency_target    = 5
  interval          = 300

  folder_uid = var.service_name
  labels     = local.grafana_labels
}
```

`interval` default is `300` (Datadog `last_5m`). Grafana provider (`url` / `auth`) is minted by `fgr tf` / `auth-terraform-providers`.
