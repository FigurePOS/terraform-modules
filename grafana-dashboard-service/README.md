# grafana-dashboard-service

Grafana recreation of `datadog-dashboard-service` for Amazon Managed Grafana.

One dashboard per service, env variable `development|production`. CloudWatch uid is `aws-cloudwatch-${env:text}`; Axiom dataset is `${env}` (`node-js-metrics-dev` / `node-js-metrics-prod`). ALB panels use CloudWatch SEARCH (not Insights, which allows only 1 query per `GetMetricData`) and match the target group by unquoted partial match on the service name — quoting it would make it an exact match on the full `targetgroup/{name}/{id}` value.

HTTP and event queries use OTEL `resource.name` (`POST /payments/payment/:id`, event name as-is), not Datadog tags (`post_/payments/payment/:id`).

Datasources stay in `infrastructure/aws/monitoring`. Dashboards go in General (root). This module only creates the dashboard JSON.

## Usage (payments)

```hcl
module "grafana_dashboard" {
  source = "github.com/FigurePOS/terraform-modules//grafana-dashboard-service?ref=<tag>"

  title         = "Payments Service"
  service       = var.service_name
  dashboard_uid = "fgr-service-payments"
  tags          = ["payments", "service"]

  http_endpoint_prefix = local.api_path_prefix

  dynamodb_tables = [
    {
      table_name = module.dynamo_payment.dynamodb_table_name
      title      = "Payment"
    },
    {
      table_name = module.dynamo_payment_configuration.dynamodb_table_name
      title      = "Configuration"
    },
  ]

  queues = [
    {
      queue_name = module.queues.queue_name
      dlq_name   = module.queues.dlq_name
      title      = "Payments Service Queue"
    },
  ]

  http_endpoints = [
    { method = "POST", route = "/auth-token" },
    { method = "POST", route = "/event" },
    { method = "GET", route = "/payment/:id" },
    { method = "POST", route = "/payment/:id" },
    { method = "POST", route = "/payment/:id/cancel" },
    { method = "POST", route = "/payment/:id/save" },
    { method = "GET", route = "/payment-audit/:id" },
  ]

  events = [
    "InteractivePaymentCancellationRequested",
    "PaymentCancelCompleted",
    "PaymentCancelInitialized",
    "PaymentCancellationChecked",
    "PaymentCancellationRequested",
    "PaymentCompleted",
    "PaymentConfigurationUpdated",
    "PaymentCredentialsValidationRequested",
    "PaymentError",
    "PaymentInitialized",
    "PaymentInitializationRequested",
    "PaymentSaveRequested",
  ]
}
```

Optional: `service_worker` adds an Application – Worker row (CPU/mem/tasks/event-loop, no ALB). Empty `dlq_name` skips the DLQ stat.

Grafana provider (`url` / `auth`) is minted by `fgr tf` / `auth-terraform-providers` — same as the monitoring stack.
