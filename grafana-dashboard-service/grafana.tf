locals {
  ecs_sections = concat(
    [{
      title        = "Application – API"
      service      = var.service
      y            = local.y_api
      row_id       = 1
      id_cpu       = 11
      id_mem       = 12
      id_tasks     = 13
      id_eventloop = 14
      include_alb  = true
    }],
    [
      for _ in range(var.service_worker == "" ? 0 : 1) : {
        title        = "Application – Worker"
        service      = var.service_worker
        y            = local.y_worker
        row_id       = 5
        id_cpu       = 51
        id_mem       = 52
        id_tasks     = 53
        id_eventloop = 54
        include_alb  = false
      }
    ],
  )

  ecs_panels = flatten([
    for s in local.ecs_sections : concat(
      [
        {
          type      = "row"
          id        = s.row_id
          title     = s.title
          gridPos   = { h = 1, w = 24, x = 0, y = s.y }
          collapsed = false
          panels    = []
        },
        merge(local.grafana_timeseries_base, {
          id          = s.id_cpu
          title       = "ECS – CPU Usage"
          gridPos     = { h = 8, w = 12, x = 0, y = s.y + 1 }
          fieldConfig = local.grafana_thresholds_pct_80_95
          targets = [
            merge(local.grafana_cw_target, {
              refId      = "A"
              namespace  = "AWS/ECS"
              metricName = "CPUUtilization"
              statistic  = "Average"
              label      = "avg"
              dimensions = { ClusterName = [var.cluster_name], ServiceName = [s.service] }
            }),
            merge(local.grafana_cw_target, {
              refId      = "B"
              namespace  = "AWS/ECS"
              metricName = "CPUUtilization"
              statistic  = "Maximum"
              label      = "max"
              dimensions = { ClusterName = [var.cluster_name], ServiceName = [s.service] }
            }),
            merge(local.grafana_cw_target, {
              refId      = "C"
              namespace  = "AWS/ECS"
              metricName = "CPUUtilization"
              statistic  = "Minimum"
              label      = "min"
              dimensions = { ClusterName = [var.cluster_name], ServiceName = [s.service] }
            }),
          ]
        }),
        merge(local.grafana_timeseries_base, {
          id          = s.id_mem
          title       = "ECS – Memory usage"
          gridPos     = { h = 8, w = 12, x = 12, y = s.y + 1 }
          fieldConfig = local.grafana_thresholds_pct_80_95
          targets = [
            merge(local.grafana_cw_target, {
              refId      = "A"
              namespace  = "AWS/ECS"
              metricName = "MemoryUtilization"
              statistic  = "Average"
              label      = "avg"
              dimensions = { ClusterName = [var.cluster_name], ServiceName = [s.service] }
            }),
            merge(local.grafana_cw_target, {
              refId      = "B"
              namespace  = "AWS/ECS"
              metricName = "MemoryUtilization"
              statistic  = "Maximum"
              label      = "max"
              dimensions = { ClusterName = [var.cluster_name], ServiceName = [s.service] }
            }),
            merge(local.grafana_cw_target, {
              refId      = "C"
              namespace  = "AWS/ECS"
              metricName = "MemoryUtilization"
              statistic  = "Minimum"
              label      = "min"
              dimensions = { ClusterName = [var.cluster_name], ServiceName = [s.service] }
            }),
          ]
        }),
        merge(local.grafana_timeseries_base, {
          id          = s.id_tasks
          title       = "Number of tasks"
          description = "Running count from Axiom (ecs_running_task_metrics). Desired is not exported."
          datasource  = local.grafana_axiom_ds
          gridPos     = { h = 8, w = 8, x = 0, y = s.y + 9 }
          targets = [
            merge(local.grafana_axiom_target, {
              refId = "A"
              query = <<-EOT
                `$${env}`:`aws.ecs.service.running_task_count`
                | where `fgr_service_name` == "${s.service}"
                | align to 1m using last
                | extend __label = "running"
              EOT
            }),
          ]
        }),
        merge(local.grafana_timeseries_base, {
          id         = s.id_eventloop
          title      = "Event Loop Delay"
          datasource = local.grafana_axiom_ds
          gridPos    = { h = 8, w = 8, x = 8, y = s.y + 9 }
          fieldConfig = {
            defaults = {
              unit = "ms"
              custom = {
                drawStyle       = "line"
                lineWidth       = 1
                fillOpacity     = 0
                thresholdsStyle = { mode = "dashed" }
              }
              thresholds = {
                mode = "absolute"
                steps = [
                  { color = "green", value = null },
                  { color = "yellow", value = 100 },
                  { color = "red", value = 250 },
                ]
              }
            }
            overrides = []
          }
          targets = [
            merge(local.grafana_axiom_target, {
              refId = "A"
              query = <<-EOT
                `$${env}`:`nodejs.eventloop.delay.p99`
                | where `service.name` == "${s.service}"
                | align to 1m using avg
                | map * 1000
                | extend __label = "p99"
              EOT
            }),
          ]
        }),
      ],
      [
        for _ in range(s.include_alb ? 1 : 0) : merge(local.grafana_timeseries_base, {
          id      = 15
          title   = "Load Balancer Responses"
          gridPos = { h = 8, w = 8, x = 16, y = s.y + 9 }
          fieldConfig = merge(local.grafana_timeseries_base.fieldConfig, {
            defaults = merge(local.grafana_timeseries_base.fieldConfig.defaults, {
              custom = merge(local.grafana_timeseries_base.fieldConfig.defaults.custom, {
                drawStyle = "bars"
                stacking  = { mode = "normal", group = "A" }
              })
            })
            overrides = [
              {
                matcher    = { id = "byName", options = "4xx" }
                properties = [{ id = "color", value = { mode = "fixed", fixedColor = "#FF9830" } }]
              },
              {
                matcher    = { id = "byName", options = "5xx" }
                properties = [{ id = "color", value = { mode = "fixed", fixedColor = "#F2495C" } }]
              },
            ]
          })
          # TargetGroup is targetgroup/{name}/{id}; the id is unknown here, so the service
          # name goes in as an unquoted SEARCH partial match. Quoting it would make it an
          # exact match on the whole dimension value and return nothing.
          targets = [
            for pair in [
              { ref = "A", id = "e2xx", metric = "HTTPCode_Target_2XX_Count", label = "2xx" },
              { ref = "B", id = "e3xx", metric = "HTTPCode_Target_3XX_Count", label = "3xx" },
              { ref = "C", id = "e4xx", metric = "HTTPCode_Target_4XX_Count", label = "4xx" },
              { ref = "D", id = "e5xx", metric = "HTTPCode_Target_5XX_Count", label = "5xx" },
              ] : merge(local.grafana_cw_search_target, {
                refId      = pair.ref
                id         = pair.id
                metricName = pair.metric
                label      = pair.label
                expression = "SUM(SEARCH('{AWS/ApplicationELB,LoadBalancer,TargetGroup} MetricName=\"${pair.metric}\" ${substr(s.service, 0, 32)}', 'Sum', 60))"
            })
          ]
        })
      ],
    )
  ])

  queue_ids = [
    for i, q in var.queues : i == 0 ? {
      row  = 2
      sent = 21
      age  = 22
      size = 24
      dlq  = 23
      } : {
      row  = 600 + i * 10
      sent = 601 + i * 10
      age  = 602 + i * 10
      size = 603 + i * 10
      dlq  = 604 + i * 10
    }
  ]

  queue_panels = flatten([
    for i, q in var.queues : concat(
      [
        {
          type      = "row"
          id        = local.queue_ids[i].row
          title     = q.title
          gridPos   = { h = 1, w = 24, x = 0, y = local.queue_ys[i] }
          collapsed = false
          panels    = []
        },
        merge(local.grafana_timeseries_base, {
          id      = local.queue_ids[i].sent
          title   = "Number of messages"
          gridPos = { h = 8, w = 8, x = 0, y = local.queue_ys[i] + 1 }
          fieldConfig = merge(local.grafana_timeseries_base.fieldConfig, {
            defaults = merge(local.grafana_timeseries_base.fieldConfig.defaults, {
              custom = merge(local.grafana_timeseries_base.fieldConfig.defaults.custom, { drawStyle = "bars" })
            })
          })
          targets = [
            merge(local.grafana_cw_target, {
              refId      = "A"
              namespace  = "AWS/SQS"
              metricName = "NumberOfMessagesSent"
              statistic  = "Sum"
              label      = "sent"
              dimensions = { QueueName = [q.queue_name] }
            }),
          ]
        }),
        merge(local.grafana_timeseries_base, {
          id      = local.queue_ids[i].age
          title   = "Number and age of messages"
          gridPos = { h = 8, w = 8, x = 8, y = local.queue_ys[i] + 1 }
          targets = [
            merge(local.grafana_cw_target, {
              refId      = "A"
              namespace  = "AWS/SQS"
              metricName = "ApproximateNumberOfMessagesVisible"
              statistic  = "Maximum"
              label      = "visible"
              dimensions = { QueueName = [q.queue_name] }
            }),
            merge(local.grafana_cw_target, {
              refId      = "B"
              namespace  = "AWS/SQS"
              metricName = "ApproximateAgeOfOldestMessage"
              statistic  = "Average"
              label      = "oldest age"
              dimensions = { QueueName = [q.queue_name] }
            }),
          ]
        }),
        merge(local.grafana_timeseries_base, {
          id      = local.queue_ids[i].size
          title   = "Message size"
          gridPos = { h = 8, w = 8, x = 16, y = local.queue_ys[i] + 1 }
          fieldConfig = merge(local.grafana_timeseries_base.fieldConfig, {
            defaults = merge(local.grafana_timeseries_base.fieldConfig.defaults, { unit = "decbytes" })
          })
          targets = [
            merge(local.grafana_cw_target, {
              refId      = "A"
              namespace  = "AWS/SQS"
              metricName = "SentMessageSize"
              statistic  = "Average"
              label      = "avg size"
              dimensions = { QueueName = [q.queue_name] }
            }),
          ]
        }),
      ],
      [
        for _ in range(q.dlq_name == "" ? 0 : 1) : {
          type       = "stat"
          id         = local.queue_ids[i].dlq
          title      = "Number of messages in dead letter"
          datasource = local.grafana_cw_ds
          gridPos    = { h = 5, w = 5, x = 0, y = local.queue_ys[i] + 9 }
          options = {
            colorMode     = "background"
            graphMode     = "none"
            justifyMode   = "center"
            textMode      = "value"
            reduceOptions = { calcs = ["max"], fields = "", values = false }
          }
          fieldConfig = {
            defaults = {
              thresholds = {
                mode = "absolute"
                steps = [
                  { color = "green", value = null },
                  { color = "red", value = 1 },
                ]
              }
            }
            overrides = []
          }
          targets = [
            merge(local.grafana_cw_target, {
              refId      = "A"
              namespace  = "AWS/SQS"
              metricName = "ApproximateNumberOfMessagesVisible"
              statistic  = "Maximum"
              dimensions = { QueueName = [q.dlq_name] }
            }),
          ]
        }
      ],
    )
  ])

  dynamo_panels = flatten([
    for ti, table in var.dynamodb_tables : [
      {
        type      = "row"
        id        = 30 + ti * 10
        title     = "DynamoDB – ${table.title}"
        gridPos   = { h = 1, w = 24, x = 0, y = local.y_dynamo + ti * 18 }
        collapsed = false
        panels    = []
      },
      merge(local.grafana_timeseries_base, {
        id      = 31 + ti * 10
        title   = "Errors and throttling"
        gridPos = { h = 8, w = 12, x = 0, y = local.y_dynamo + ti * 18 + 1 }
        fieldConfig = merge(local.grafana_timeseries_base.fieldConfig, {
          defaults = merge(local.grafana_timeseries_base.fieldConfig.defaults, {
            custom = merge(local.grafana_timeseries_base.fieldConfig.defaults.custom, {
              drawStyle       = "bars"
              thresholdsStyle = { mode = "dashed" }
            })
            thresholds = {
              mode = "absolute"
              steps = [
                { color = "green", value = null },
                { color = "yellow", value = 1 },
                { color = "red", value = 10 },
              ]
            }
          })
        })
        targets = [
          for pair in [
            { ref = "A", metric = "UserErrors", label = "user errors" },
            { ref = "B", metric = "SystemErrors", label = "system errors" },
            { ref = "C", metric = "ThrottledRequests", label = "throttled" },
            ] : merge(local.grafana_cw_target, {
              refId      = pair.ref
              namespace  = "AWS/DynamoDB"
              metricName = pair.metric
              statistic  = "Sum"
              label      = pair.label
              matchExact = false
              dimensions = {
                TableName = [table.table_name]
                Operation = ["*"]
              }
          })
        ]
      }),
      merge(local.grafana_timeseries_base, {
        id      = 32 + ti * 10
        title   = "Successful request latency"
        gridPos = { h = 8, w = 12, x = 12, y = local.y_dynamo + ti * 18 + 1 }
        fieldConfig = merge(local.grafana_timeseries_base.fieldConfig, {
          defaults = merge(local.grafana_timeseries_base.fieldConfig.defaults, {
            unit = "ms"
            custom = merge(local.grafana_timeseries_base.fieldConfig.defaults.custom, {
              thresholdsStyle = { mode = "dashed" }
            })
            thresholds = {
              mode = "absolute"
              steps = [
                { color = "green", value = null },
                { color = "yellow", value = 25 },
                { color = "red", value = 100 },
              ]
            }
          })
        })
        targets = [
          merge(local.grafana_cw_insights_target, {
            refId         = "A"
            namespace     = "AWS/DynamoDB"
            metricName    = "SuccessfulRequestLatency"
            statistic     = "Average"
            label         = "avg"
            sqlExpression = "SELECT AVG(SuccessfulRequestLatency) FROM SCHEMA(\"AWS/DynamoDB\", TableName, Operation) WHERE TableName = '${table.table_name}'"
          }),
        ]
      }),
      merge(local.grafana_timeseries_base, {
        id      = 33 + ti * 10
        title   = "Read and write throughput"
        gridPos = { h = 8, w = 12, x = 0, y = local.y_dynamo + ti * 18 + 9 }
        fieldConfig = merge(local.grafana_timeseries_base.fieldConfig, {
          defaults = merge(local.grafana_timeseries_base.fieldConfig.defaults, {
            custom = merge(local.grafana_timeseries_base.fieldConfig.defaults.custom, {
              drawStyle    = "bars"
              gradientMode = "hue"
              stacking     = { mode = "normal", group = "A" }
            })
          })
        })
        targets = [
          merge(local.grafana_cw_target, {
            refId      = "A"
            namespace  = "AWS/DynamoDB"
            metricName = "ConsumedReadCapacityUnits"
            statistic  = "Sum"
            label      = "read"
            dimensions = { TableName = [table.table_name] }
          }),
          merge(local.grafana_cw_target, {
            refId      = "B"
            namespace  = "AWS/DynamoDB"
            metricName = "ConsumedWriteCapacityUnits"
            statistic  = "Sum"
            label      = "write"
            dimensions = { TableName = [table.table_name] }
          }),
        ]
      }),
      merge(local.grafana_timeseries_base, {
        id      = 34 + ti * 10
        title   = "Item count"
        gridPos = { h = 8, w = 12, x = 12, y = local.y_dynamo + ti * 18 + 9 }
        targets = [
          merge(local.grafana_cw_target, {
            refId      = "A"
            namespace  = "AWS/DynamoDB"
            metricName = "ItemCount"
            statistic  = "Maximum"
            label      = "items"
            period     = "3600"
            dimensions = { TableName = [table.table_name] }
          }),
        ]
      }),
    ]
  ])

  http_panels = concat(
    [
      for _ in range(length(var.http_endpoints) == 0 ? 0 : 1) : {
        type      = "row"
        id        = 3
        title     = "API Requests"
        gridPos   = { h = 1, w = 24, x = 0, y = local.y_http }
        collapsed = false
        panels    = []
      }
    ],
    [
      for i, ep in local.http_endpoints : merge(local.grafana_timeseries_base, {
        id          = 100 + i
        title       = ep.title
        datasource  = local.grafana_axiom_ds
        gridPos     = { h = 8, w = 12, x = (i % 2) * 12, y = local.y_http + 1 + floor(i / 2) * 8 }
        fieldConfig = local.http_red_field_config
        targets = [
          merge(local.grafana_axiom_target, {
            refId = "A"
            query = <<-EOT
              `$${env}`:`fgr.http.server.request.count`
              | where `service.name` == "${var.service}"
              | where `resource.name` ${ep.where_resource}
              | map rate
              | align to 1m using avg
              | group using sum
              | extend __label = "count"
            EOT
          }),
          merge(local.grafana_axiom_target, {
            refId = "B"
            query = <<-EOT
              `$${env}`:`fgr.http.server.request.errors`
              | where `service.name` == "${var.service}"
              | where `resource.name` ${ep.where_resource}
              | map rate
              | align to 1m using avg
              | group using sum
              | extend __label = "errors"
            EOT
          }),
          merge(local.grafana_axiom_target, {
            refId = "C"
            query = <<-EOT
              `$${env}`:`fgr.http.server.request.duration`
              | where `service.name` == "${var.service}"
              | where `resource.name` ${ep.where_resource}
              | bucket to 1m using interpolate_delta_histogram(0.99)
              | map * 1000
              | extend __label = "p99 ms"
            EOT
          }),
        ]
      })
    ]
  )

  event_panels = concat(
    [
      for _ in range(length(var.events) == 0 ? 0 : 1) : {
        type      = "row"
        id        = 4
        title     = "Events"
        gridPos   = { h = 1, w = 24, x = 0, y = local.y_events }
        collapsed = false
        panels    = []
      }
    ],
    [
      for i, event in var.events : merge(local.grafana_timeseries_base, {
        id          = 200 + i
        title       = event
        datasource  = local.grafana_axiom_ds
        gridPos     = { h = 8, w = 12, x = (i % 2) * 12, y = local.y_events + 1 + floor(i / 2) * 8 }
        fieldConfig = local.http_red_field_config
        targets = [
          merge(local.grafana_axiom_target, {
            refId = "A"
            query = <<-EOT
              `$${env}`:`fgr.message.consumer.count`
              | where `service.name` ${local.event_service_where}
              | where `resource.name` == "${event}"
              | align to 1m using sum
              | group using sum
              | extend __label = "count"
            EOT
          }),
          merge(local.grafana_axiom_target, {
            refId = "B"
            query = <<-EOT
              `$${env}`:`fgr.message.consumer.errors`
              | where `service.name` ${local.event_service_where}
              | where `resource.name` == "${event}"
              | align to 1m using sum
              | group using sum
              | extend __label = "errors"
            EOT
          }),
          merge(local.grafana_axiom_target, {
            refId = "C"
            query = <<-EOT
              `$${env}`:`fgr.message.consumer.duration`
              | where `service.name` ${local.event_service_where}
              | where `resource.name` == "${event}"
              | bucket to 1m using interpolate_delta_histogram(0.95)
              | map * 1000
              | extend __label = "p95 ms"
            EOT
          }),
        ]
      })
    ]
  )
}

resource "grafana_dashboard" "service" {
  overwrite = true

  config_json = jsonencode({
    uid           = local.dashboard_uid
    title         = var.title
    timezone      = "browser"
    schemaVersion = 39
    editable      = true
    graphTooltip  = 1
    time          = { from = "now-1h", to = "now" }
    refresh       = "1m"
    tags          = var.tags
    templating = {
      list = [
        {
          name  = "env"
          type  = "custom"
          label = "Environment"
          query = "development : node-js-metrics-dev,production : node-js-metrics-prod"
          current = {
            text  = "production"
            value = "node-js-metrics-prod"
          }
          options = [
            { text = "development", value = "node-js-metrics-dev", selected = false },
            { text = "production", value = "node-js-metrics-prod", selected = true },
          ]
          includeAll = false
          multi      = false
        },
      ]
    }
    panels = concat(
      local.ecs_panels,
      local.queue_panels,
      local.dynamo_panels,
      local.http_panels,
      local.event_panels,
    )
  })
}
