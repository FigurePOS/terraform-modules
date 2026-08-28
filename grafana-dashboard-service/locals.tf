locals {
  dashboard_uid = coalesce(var.dashboard_uid, var.service)

  grafana_cw_ds = {
    type = "cloudwatch"
    uid  = "aws-cloudwatch-$${env:text}"
  }

  grafana_axiom_ds = {
    type = "axiomhq-axiom-datasource"
    uid  = "axiom"
  }

  grafana_cw_target = {
    datasource       = local.grafana_cw_ds
    queryMode        = "Metrics"
    metricQueryType  = 0
    metricEditorMode = 0
    region           = "default"
    matchExact       = true
    period           = ""
  }

  # DynamoDB Operation-scoped metrics: single aggregation only (no AS aliases).
  grafana_cw_insights_target = {
    datasource       = local.grafana_cw_ds
    queryMode        = "Metrics"
    metricQueryType  = 1
    metricEditorMode = 1
    region           = "default"
    matchExact       = false
    period           = ""
    dimensions       = {}
  }

  # Classic metric math (multiple queries per panel; AMG limits Insights to 1).
  grafana_cw_math_target = {
    datasource       = local.grafana_cw_ds
    queryMode        = "Metrics"
    metricQueryType  = 0
    metricEditorMode = 1
    region           = "default"
    matchExact       = false
    period           = ""
    namespace        = ""
    metricName       = ""
    statistic        = "Sum"
    dimensions       = {}
  }

  grafana_axiom_target = {
    datasource = local.grafana_axiom_ds
    kind       = "mpl"
    version    = "2.0"
    totals     = false
  }

  grafana_timeseries_options = {
    legend = {
      displayMode = "list"
      placement   = "bottom"
      showLegend  = true
    }
    tooltip = { mode = "multi" }
  }

  grafana_timeseries_base = {
    type       = "timeseries"
    datasource = local.grafana_cw_ds
    options    = local.grafana_timeseries_options
    fieldConfig = {
      defaults = {
        custom = {
          drawStyle   = "line"
          lineWidth   = 1
          fillOpacity = 10
          spanNulls   = false
        }
      }
      overrides = []
    }
  }

  grafana_thresholds_pct_80_95 = {
    defaults = {
      unit = "percent"
      custom = {
        drawStyle       = "line"
        lineWidth       = 1
        fillOpacity     = 10
        axisSoftMin     = 0
        axisSoftMax     = 100
        thresholdsStyle = { mode = "dashed" }
      }
      thresholds = {
        mode = "absolute"
        steps = [
          { color = "green", value = null },
          { color = "yellow", value = 80 },
          { color = "red", value = 95 },
        ]
      }
    }
    overrides = [
      {
        matcher = { id = "byName", options = "max" }
        properties = [
          { id = "custom.lineStyle", value = { fill = "dot", dash = [0, 4] } },
          { id = "custom.lineWidth", value = 1 },
          { id = "color", value = { mode = "fixed", fixedColor = "#999999" } },
        ]
      },
      {
        matcher = { id = "byName", options = "min" }
        properties = [
          { id = "custom.lineStyle", value = { fill = "dot", dash = [0, 4] } },
          { id = "custom.lineWidth", value = 1 },
          { id = "color", value = { mode = "fixed", fixedColor = "#999999" } },
        ]
      },
    ]
  }

  http_red_field_config = {
    defaults = {
      custom = {
        drawStyle   = "bars"
        lineWidth   = 1
        fillOpacity = 20
        spanNulls   = false
      }
    }
    overrides = [
      {
        matcher = { id = "byRegexp", options = "^p9[59] ms$" }
        properties = [
          { id = "custom.drawStyle", value = "line" },
          { id = "custom.axisPlacement", value = "right" },
          { id = "unit", value = "ms" },
          { id = "custom.fillOpacity", value = 0 },
        ]
      },
    ]
  }

  http_endpoints = [
    for e in var.http_endpoints : {
      title          = "${upper(e.method) == "ANY" ? "*" : upper(e.method)} ${e.route}"
      where_resource = upper(e.method) == "ANY" ? "endswith \" /${var.http_endpoint_prefix}${e.route}\"" : "== \"${upper(e.method)} /${var.http_endpoint_prefix}${e.route}\""
    }
  ]

  # Layout: API (17) + optional worker (17) + queues (14 with DLQ, 9 without) + Dynamo (18 each) + HTTP + events.
  y_api    = 0
  api_h    = 17
  worker_h = var.service_worker == "" ? 0 : 17
  y_worker = local.y_api + local.api_h
  y_queue  = local.y_api + local.api_h + local.worker_h

  queue_heights = [for q in var.queues : 1 + 8 + (q.dlq_name == "" ? 0 : 5)]
  queue_ys = [
    for i, q in var.queues : local.y_queue + (
      i == 0 ? 0 : sum(slice(local.queue_heights, 0, i))
    )
  ]
  queues_h = length(var.queues) == 0 ? 0 : sum(local.queue_heights)

  y_dynamo  = local.y_queue + local.queues_h
  dynamo_h  = length(var.dynamodb_tables) * 18
  y_http    = local.y_dynamo + local.dynamo_h
  http_h    = length(var.http_endpoints) == 0 ? 0 : 1 + (floor((length(var.http_endpoints) + 1) / 2) * 8)
  y_events  = local.y_http + local.http_h
}
