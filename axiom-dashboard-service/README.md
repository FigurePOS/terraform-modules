# axiom-dashboard-service

Per-service dashboard in Axiom. Mirrors the inputs of `datadog-dashboard-service`
and `cloudwatch-dashboard-service` so a service repo can wire the same values
into all three (or pick one) during the Datadog migration.

## Inputs

| Name | Type | Default | Notes |
| --- | --- | --- | --- |
| `title` | string | — | Dashboard title in the Axiom UI. |
| `service` | string | — | Primary ECS service name. Filters SQS/ECS/ALB/traces. |
| `service_worker` | string | `""` | Optional worker ECS service name. When set, duplicates the ECS group. |
| `env` | string | — | `development` or `production` — selects the dataset suffix (`-dev` / `-prod`). |
| `api_path_prefix` | string | — | Matches `datadog-dashboard-service.api_path_prefix` (no leading slash). |
| `http_endpoints` | list | `[]` | Each `{ method, route }` becomes an APM widget (APL over traces). |
| `queues` | list | `[]` | Each `{ queue_name, dlq_name, title }` becomes an SQS group. |
| `events` | list(string) | `[]` | Each event becomes a message-consumer APM widget (APL over traces). |

## Data sources

| Section | Dataset | Query type |
| --- | --- | --- |
| Application (ECS CPU/Memory, Event Loop) | `node-js-metrics-{env}` | APL over MetricsDB |
| Load Balancer (2xx/3xx/4xx/5xx) | `node-js-metrics-{env}` | APL over MetricsDB |
| SQS Queues (sent/visible/age/size/DLQ) | `node-js-metrics-{env}` | APL over MetricsDB |
| APM – HTTP Endpoints | `node-js-traces-{env}` | APL over traces |
| Events – message consumers | `node-js-traces-{env}` | APL over traces |
| API latency | `node-js-traces-{env}` | APL over traces |

Metric-dataset widgets rely on AWS-native metrics collected by the YACE sidecar
in `infrastructure/aws/app/otel_collector`. Rename/attribute-mapping processors
normalize YACE's Prometheus-style names to OTel dot-notation — see
`infrastructure/docs/telemetry/datadog-migration-2026/ecs-otel-switch-plan.md`.

## Known limitations

### 1. APL against metrics datasets may fail via the provider

The `axiomhq/axiom` Terraform provider (≤ 1.6.0) routes all APL queries through
the event-query engine, which rejects `otel:metrics:v1` datasets. See upstream
issue [axiomhq/terraform-provider-axiom#86](https://github.com/axiomhq/terraform-provider-axiom/issues/86).

**Impact**: the ECS / ALB / SQS / Event-loop widgets are created with valid APL
but may render as "Query failed" until the provider exposes the metrics-query
endpoint. **Workaround**: rebuild the affected charts in the Axiom UI (Builder
tab supports metrics datasets natively) and keep this module for the trace
widgets. Once the provider is fixed, switch back to the module.

### 2. ECS task counts (`running` / `desired`) not yet collected

AWS/ECS in CloudWatch doesn't expose task counts without Container Insights, so
YACE can't scrape them. The dashboard renders a placeholder spacer for the
"Number of tasks" slot. See
`infrastructure/docs/telemetry/datadog-migration-2026/ecs-service-counts-lambda-plan.md`
for the planned Lambda-based backfill.

### 3. Layout is empty on first apply

The Axiom dashboard v2 grid-layout schema isn't publicly documented beyond the
top-level `layout` array. This module ships `layout = []`; Axiom auto-places
charts. Rearrange in the UI, then (optionally) capture the resulting array via:

```bash
curl -H "Authorization: Bearer $AXIOM_TOKEN" \
  https://api.axiom.co/v2/dashboards/uid/fgr-service-<service>-<env> \
  | jq .layout
```

and paste it back into the `layout = []` line in `dashboard.tf` to freeze
positions.

### 4. Field names in `attributes.*` are a best-guess

Trace widgets assume the flattened OTel layout (`attributes.http.route`,
`attributes.http.request.method`, `attributes.http.response.status_code`,
`attributes.messaging.destination.name`). If your `fgr-lib-backend` version
emits these under different paths (e.g., legacy `http.method`), adjust the
query fragments in `dashboard.tf`. A single `fgr-lib-backend` upgrade will
usually migrate all services at once.

## Usage

```hcl
module "axiom_dashboard" {
  source = "github.com/FigurePOS/terraform-modules//axiom-dashboard-service?ref=v11.X.0"

  title           = "Business Config"
  service         = "fgr-service-business-config"
  service_worker  = "fgr-service-business-config-worker"
  env             = var.env
  api_path_prefix = "v1"

  http_endpoints = [
    { method = "GET",  route = "/account" },
    { method = "POST", route = "/account" },
    { method = "GET",  route = "/pricing/:id" },
  ]

  queues = [
    {
      queue_name = "fgr-service-business-config-events"
      dlq_name   = "fgr-service-business-config-events-dlq"
      title      = "Events"
    },
  ]

  events = ["OrderCreated", "OrderShipped"]
}
```

The module declares `axiomhq/axiom ~> 1.5`; ensure the consumer stack has the
provider configured (see `infrastructure/axiom/general.tf` for the
`api_token`).
