locals {
  env_suffix       = var.env == "production" ? "prod" : "dev"
  metrics_dataset  = "node-js-metrics-${local.env_suffix}"
  traces_dataset   = "node-js-traces-${local.env_suffix}"
  include_worker   = var.service_worker != ""
  include_http     = length(var.http_endpoints) > 0
  include_events   = length(var.events) > 0

  http_endpoint_rows = [
    for e in var.http_endpoints : {
      title     = "${upper(e.method) == "ANY" ? "*" : upper(e.method)} /${var.api_path_prefix}${e.route}"
      slug      = replace("${lower(e.method)}_${var.api_path_prefix}${e.route}", "/[^a-z0-9_]/", "_")
      method    = e.method
      full_path = "/${var.api_path_prefix}${e.route}"
    }
  ]

  # -------------------------------------------------------------------------
  # Helpers for common APL fragments.
  # NOTE: Field names in Axiom's MetricsDB and traces datasets follow the
  # flattened OTel layout. If your dataset uses different field paths, adjust
  # the `metric_where_*` and trace filters below.
  # -------------------------------------------------------------------------
  filter_env   = "['deployment.environment'] == '${var.env}'"
  filter_svc   = "['service.name'] == '${var.service}'"
  filter_svc_w = "['service.name'] == '${var.service_worker}'"
}

# ----------------------------------------------------------------------------
# Application – API
# ----------------------------------------------------------------------------
locals {
  api_charts = [
    {
      id    = "section-api"
      type  = "Spacer"
      name  = "Application – API (${var.service})"
      query = null
    },
    {
      id   = "api-ecs-cpu"
      type = "TimeSeries"
      name = "ECS – CPU Usage"
      query = {
        apl = <<-APL
          ['${local.metrics_dataset}']
          | where metric in ('aws.ecs.cpuutilization_average', 'aws.ecs.cpuutilization_maximum', 'aws.ecs.cpuutilization_minimum')
          | where ['aws.ecs.service.name'] == '${var.service}'
          | summarize avg(value) by metric, bin_auto(_time)
        APL
      }
    },
    {
      id   = "api-ecs-mem"
      type = "TimeSeries"
      name = "ECS – Memory usage"
      query = {
        apl = <<-APL
          ['${local.metrics_dataset}']
          | where metric in ('aws.ecs.memory_utilization_average', 'aws.ecs.memory_utilization_maximum', 'aws.ecs.memory_utilization_minimum')
          | where ['aws.ecs.service.name'] == '${var.service}'
          | summarize avg(value) by metric, bin_auto(_time)
        APL
      }
    },
    # Task counts (running / desired) are NOT in AWS/ECS without Container
    # Insights. Datadog publishes them by polling the ECS API directly; we
    # replicate that with a Lambda described in
    # infrastructure/docs/telemetry/datadog-migration-2026/ecs-service-counts-lambda-plan.md.
    # Placeholder spacer kept here so the layout slot is reserved.
    {
      id    = "api-tasks-placeholder"
      type  = "Spacer"
      name  = "Number of tasks – TODO: populated by ecs-service-counts Lambda (see plan)"
      query = null
    },
    {
      id   = "api-eventloop"
      type = "TimeSeries"
      name = "Event Loop Utilization"
      query = {
        apl = <<-APL
          ['${local.metrics_dataset}']
          | where metric == 'nodejs.eventloop.utilization'
          | where ${local.filter_svc}
          | summarize avg(value) by bin_auto(_time)
        APL
      }
    },
  ]
}

# ----------------------------------------------------------------------------
# Application – Worker (optional)
# ----------------------------------------------------------------------------
# The `for ... if` pattern keeps both branches of the conditional structurally
# compatible (same element type). A plain ternary with `[]` trips HCL's tuple
# type inference because spacer objects and time-series objects have different
# attribute sets.
locals {
  worker_charts = [
    for c in [
      {
        id    = "section-worker"
        type  = "Spacer"
        name  = "Application – Worker (${var.service_worker})"
        query = null
      },
      {
        id   = "worker-ecs-cpu"
        type = "TimeSeries"
        name = "ECS – CPU Usage"
        query = {
          apl = <<-APL
            ['${local.metrics_dataset}']
            | where metric in ('aws.ecs.cpuutilization_average', 'aws.ecs.cpuutilization_maximum', 'aws.ecs.cpuutilization_minimum')
            | where ['aws.ecs.service.name'] == '${var.service_worker}'
            | summarize avg(value) by metric, bin_auto(_time)
          APL
        }
      },
      {
        id   = "worker-ecs-mem"
        type = "TimeSeries"
        name = "ECS – Memory usage"
        query = {
          apl = <<-APL
            ['${local.metrics_dataset}']
            | where metric in ('aws.ecs.memory_utilization_average', 'aws.ecs.memory_utilization_maximum', 'aws.ecs.memory_utilization_minimum')
            | where ['aws.ecs.service.name'] == '${var.service_worker}'
            | summarize avg(value) by metric, bin_auto(_time)
          APL
        }
      },
      {
        id    = "worker-tasks-placeholder"
        type  = "Spacer"
        name  = "Number of tasks – TODO: populated by ecs-service-counts Lambda (see plan)"
        query = null
      },
      {
        id   = "worker-eventloop"
        type = "TimeSeries"
        name = "Event Loop Utilization"
        query = {
          apl = <<-APL
            ['${local.metrics_dataset}']
            | where metric == 'nodejs.eventloop.utilization'
            | where ${local.filter_svc_w}
            | summarize avg(value) by bin_auto(_time)
          APL
        }
      },
    ] : c if local.include_worker
  ]
}

# ----------------------------------------------------------------------------
# Load Balancer
# ----------------------------------------------------------------------------
# YACE emits aws.applicationelb metrics dimensioned by (LoadBalancer, TargetGroup).
# We match target groups whose name starts with "targetgroup/<service>" to scope
# widgets to this service — the same convention the Datadog dashboard uses.
locals {
  alb_codes = ["2xx", "3xx", "4xx", "5xx"]

  alb_charts = concat(
    [
      {
        id    = "section-alb"
        type  = "Spacer"
        name  = "Load Balancer (${var.service})"
        query = null
      },
    ],
    [
      for code in local.alb_codes : {
        id   = "alb-${code}"
        type = "TimeSeries"
        name = "${code} responses"
        query = {
          apl = <<-APL
            ['${local.metrics_dataset}']
            | where metric == 'aws.applicationelb.httpcode_target_${code}_count_sum'
            | where ['aws.alb.target_group'] startswith 'targetgroup/${var.service}'
            | summarize sum(value) by bin_auto(_time)
          APL
        }
      }
    ],
  )
}

# ----------------------------------------------------------------------------
# SQS Queues (per queue)
# ----------------------------------------------------------------------------
locals {
  sqs_charts = flatten([
    for q in var.queues : concat(
      [
        {
          id    = "section-sqs-${q.queue_name}"
          type  = "Spacer"
          name  = "${q.title} (${q.queue_name})"
          query = null
        },
        {
          id   = "sqs-${q.queue_name}-sent"
          type = "TimeSeries"
          name = "Number of messages"
          query = {
            apl = <<-APL
              ['${local.metrics_dataset}']
              | where metric == 'aws.sqs.number_of_messages_sent_sum'
              | where ['aws.sqs.queue.name'] == '${q.queue_name}'
              | summarize sum(value) by bin_auto(_time)
            APL
          }
        },
        {
          id   = "sqs-${q.queue_name}-visible"
          type = "TimeSeries"
          name = "Visible messages (max) and age of oldest (avg)"
          query = {
            apl = <<-APL
              ['${local.metrics_dataset}']
              | where metric in ('aws.sqs.approximate_number_of_messages_visible_maximum', 'aws.sqs.approximate_age_of_oldest_message_average')
              | where ['aws.sqs.queue.name'] == '${q.queue_name}'
              | summarize avg(value) by metric, bin_auto(_time)
            APL
          }
        },
        {
          id   = "sqs-${q.queue_name}-size"
          type = "TimeSeries"
          name = "Message size"
          query = {
            apl = <<-APL
              ['${local.metrics_dataset}']
              | where metric == 'aws.sqs.sent_message_size_average'
              | where ['aws.sqs.queue.name'] == '${q.queue_name}'
              | summarize avg(value) by bin_auto(_time)
            APL
          }
        },
      ],
      q.dlq_name != "" ? [
        {
          id   = "sqs-${q.queue_name}-dlq"
          type = "TimeSeries"
          name = "Dead-letter queue messages"
          query = {
            apl = <<-APL
              ['${local.metrics_dataset}']
              | where metric == 'aws.sqs.approximate_number_of_messages_visible_maximum'
              | where ['aws.sqs.queue.name'] == '${q.dlq_name}'
              | summarize max(value) by bin_auto(_time)
            APL
          }
        },
      ] : [],
    )
  ])
}

# ----------------------------------------------------------------------------
# APM – HTTP endpoints
# ----------------------------------------------------------------------------
# Derived on-demand from spans in the traces dataset. One chart per endpoint
# renders hits, 4xx/5xx errors, and p99 latency side-by-side. This matches
# Axiom's recommendation to use APL-over-traces instead of pre-computed
# Datadog-style trace.* metrics.
locals {
  apm_charts = [
    for c in concat(
      [
        {
          id    = "section-apm"
          type  = "Spacer"
          name  = "APM – HTTP Endpoints"
          query = null
        },
      ],
      [
        for row in local.http_endpoint_rows : {
          id   = "apm-${row.slug}"
          type = "TimeSeries"
          name = row.title
          query = {
            apl = <<-APL
              ['${local.traces_dataset}']
              | where ${local.filter_svc}
              | where kind == 'server'
              | where ${upper(row.method) == "ANY" ? "true" : "['attributes.http.request.method'] == '${upper(row.method)}'"}
              | where ['attributes.http.route'] == '${row.full_path}'
              | summarize
                  hits   = count(),
                  errors = countif(toint(['attributes.http.response.status_code']) >= 400),
                  p99_ms = percentile(duration / 1000000, 99)
                by bin_auto(_time)
            APL
          }
        }
      ],
    ) : c if local.include_http
  ]
}

# ----------------------------------------------------------------------------
# Events – message consumers
# ----------------------------------------------------------------------------
# Datadog used trace.figure.message.consumer metrics pre-aggregated from spans;
# Axiom equivalent is APL over the traces dataset. Adjust the name/attribute
# filter below if your consumer spans use a different convention (e.g., span
# name vs. messaging.destination.name attribute).
locals {
  event_charts = [
    for c in concat(
      [
        {
          id    = "section-events"
          type  = "Spacer"
          name  = "Events – message consumers"
          query = null
        },
      ],
      [
        for ev in var.events : {
          id   = "event-${replace(lower(ev), "/[^a-z0-9]/", "-")}"
          type = "TimeSeries"
          name = ev
          query = {
            apl = <<-APL
              ['${local.traces_dataset}']
              | where ${local.filter_svc}
              | where kind == 'consumer'
              | where tolower(['attributes.messaging.destination.name']) == '${lower(ev)}'
                  or tolower(name) == '${lower(ev)}'
              | summarize
                  hits   = count(),
                  p95_ms = percentile(duration / 1000000, 95)
                by bin_auto(_time)
            APL
          }
        }
      ],
    ) : c if local.include_events
  ]
}

# ----------------------------------------------------------------------------
# API latency
# ----------------------------------------------------------------------------
# Datadog used trace.http.server.request max. Axiom equivalent: APL over the
# traces dataset, percentiles computed on-demand from span durations.
locals {
  latency_charts = [
    {
      id    = "section-latency"
      type  = "Spacer"
      name  = "API latency (${var.service})"
      query = null
    },
    {
      id   = "api-latency"
      type = "TimeSeries"
      name = "API latency (server spans, p50/p95/p99/max)"
      query = {
        apl = <<-APL
          ['${local.traces_dataset}']
          | where ${local.filter_svc}
          | where kind == 'server'
          | summarize
              p50_ms = percentile(duration / 1000000, 50),
              p95_ms = percentile(duration / 1000000, 95),
              p99_ms = percentile(duration / 1000000, 99),
              max_ms = max(duration / 1000000)
            by bin_auto(_time)
        APL
      }
    },
  ]
}

# ----------------------------------------------------------------------------
# Dashboard resource
# ----------------------------------------------------------------------------
# Every chart local carries a `query` attribute so the lists share a common
# element type (required for HCL tuple inference across conditional lists).
# For Spacer charts, `query` is null; strip it here before jsonencode because
# Axiom's dashboard schema sets `additionalProperties: false` on Spacer and
# would reject `"query": null`.
locals {
  all_charts_raw = concat(
    local.api_charts,
    local.worker_charts,
    local.alb_charts,
    local.sqs_charts,
    local.apm_charts,
    local.event_charts,
    local.latency_charts,
  )

  all_charts = [
    for c in local.all_charts_raw : {
      for k, v in c : k => v if v != null
    }
  ]
}

resource "axiom_dashboard" "service" {
  uid       = "fgr-service-${var.service}-${local.env_suffix}"
  overwrite = true

  dashboard = jsonencode({
    name            = var.title
    description     = "Service dashboard for ${var.service} (${var.env}). Managed by terraform-modules/axiom-dashboard-service."
    owner           = "X-AXIOM-EVERYONE"
    schemaVersion   = 2
    refreshTime     = 60
    timeWindowStart = "qr-now-1h"
    timeWindowEnd   = "qr-now"
    charts          = local.all_charts
    # Layout left empty on first apply. Arrange charts in the Axiom UI, then
    # (optionally) export the dashboard JSON via `GET /v2/dashboards/uid/{uid}`
    # and paste the returned layout array back here to make positioning
    # reproducible.
    layout = []
  })
}
