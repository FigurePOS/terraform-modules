locals {
  events_service = "${var.service}*"

  http_endpoints = [
    for e in var.http_endpoints : {
      title       = "${upper(e.method) == "ANY" ? "*" : upper(e.method)} ${e.route}"
      http_method = lower(e.method)
      http_route  = "/${var.api_path_prefix}${e.route}"
      metric_dims = join(",", [
        "service:${var.service}",
        "$env",
        "http.method:${lower(e.method)}",
        "http.route:/${var.api_path_prefix}${e.route}",
      ])
    }
  ]
}

resource "datadog_dashboard" "service_dashboard" {
  title        = var.title
  layout_type  = "ordered"
  reflow_type  = "auto"

  template_variable {
    name     = "env"
    prefix   = "env"
    defaults = ["production"]
  }

  ##################################################
  # Application – API
  ##################################################
  widget {
    group_definition {
      title       = "Application – API"
      layout_type = "ordered"

      # ECS – CPU Usage
      widget {
        timeseries_definition {
          show_legend = true
          title       = "ECS – CPU Usage"

          request {
            display_type = "line"
            q            = "avg:aws.ecs.service.cpuutilization{servicename:${var.service},$env}"
            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          request {
            display_type = "line"
            q            = "avg:aws.ecs.service.cpuutilization.maximum{servicename:${var.service},$env}"
            style {
              line_type  = "dotted"
              line_width = "thin"
              palette    = "grey"
            }
          }

          request {
            display_type = "line"
            q            = "avg:aws.ecs.service.cpuutilization.minimum{servicename:${var.service},$env}"
            style {
              line_type  = "dotted"
              line_width = "thin"
              palette    = "grey"
            }
          }

          marker {
            display_type = "warning dashed"
            value        = "y = 80"
          }

          marker {
            display_type = "error dashed"
            value        = "y = 95"
          }

          yaxis {
            include_zero = true
            max          = "auto"
            min          = "auto"
            scale        = "linear"
          }
        }
      }

      # ECS – Memory usage
      widget {
        timeseries_definition {
          show_legend = true
          title       = "ECS – Memory usage"

          request {
            display_type = "line"
            q            = "avg:aws.ecs.service.memory_utilization{servicename:${var.service},$env}"
            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          request {
            display_type = "line"
            q            = "avg:aws.ecs.service.memory_utilization.minimum{servicename:${var.service},$env}"
            style {
              line_type  = "dotted"
              line_width = "thin"
              palette    = "grey"
            }
          }

          request {
            display_type = "line"
            q            = "avg:aws.ecs.service.memory_utilization.maximum{servicename:${var.service},$env}"
            style {
              line_type  = "dotted"
              line_width = "thin"
              palette    = "grey"
            }
          }

          marker {
            display_type = "warning dashed"
            value        = "y = 80"
          }

          marker {
            display_type = "error dashed"
            value        = "y = 95"
          }

          yaxis {
            include_zero = true
            max          = "auto"
            min          = "auto"
            scale        = "linear"
          }
        }
      }

      # Number of tasks
      widget {
        timeseries_definition {
          show_legend = true
          title       = "Number of tasks"

          request {
            display_type = "line"
            q            = "max:aws.ecs.service.running{service:${var.service},$env}"
            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          request {
            display_type = "line"
            q            = "avg:aws.ecs.service.desired{service:${var.service},$env}"
            style {
              line_type  = "dashed"
              line_width = "thin"
              palette    = "grey"
            }
          }

          yaxis {
            include_zero = true
            max          = "auto"
            min          = "auto"
            scale        = "linear"
          }
        }
      }

      # Event Loop Delay
      widget {
        timeseries_definition {
          show_legend = true
          title       = "Event Loop Delay"

          request {
            display_type = "line"
            q            = "(avg:nodejs.eventloop.delay.p99{service:${var.service},$env}) * 1000"
            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          marker {
            display_type = "warning dashed"
            value        = "y = 100"
          }

          marker {
            display_type = "error dashed"
            value        = "y = 250"
          }

          yaxis {
            include_zero = true
            max          = "auto"
            min          = "auto"
            scale        = "linear"
          }
        }
      }

      # Load Balancer Responses
      widget {
        timeseries_definition {
          show_legend = true
          title       = "Load Balancer Responses"

          request {
            display_type = "bars"
            q            = "sum:aws.applicationelb.httpcode_target_2xx{targetgroup:targetgroup/${var.service}/*,$env}.as_count()"
            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          request {
            display_type = "bars"
            q            = "sum:aws.applicationelb.httpcode_target_3xx{targetgroup:targetgroup/${var.service}/*,$env}.as_count()"
            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          request {
            display_type = "bars"
            q            = "sum:aws.applicationelb.httpcode_target_4xx{targetgroup:targetgroup/${var.service}/*,$env}.as_count()"
            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "orange"
            }
          }

          request {
            display_type = "bars"
            q            = "sum:aws.applicationelb.httpcode_target_5xx{targetgroup:targetgroup/${var.service}/*,$env}.as_count()"
            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "red"
            }
          }

          yaxis {
            include_zero = true
            max          = "auto"
            min          = "auto"
            scale        = "linear"
          }
        }
      }
    }
  }

  ##################################################
  # Application – Worker
  ##################################################
  dynamic "widget" {
    for_each = var.service_worker == "" ? [] : [true]
    content {
      group_definition {
        title       = "Application – Worker"
        layout_type = "ordered"

        # ECS – CPU Usage
        widget {
          timeseries_definition {
            show_legend = true
            title       = "ECS – CPU Usage"

            request {
              display_type = "line"
              q            = "avg:aws.ecs.service.cpuutilization{servicename:${var.service_worker},$env}"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "dog_classic"
              }
            }

            request {
              display_type = "line"
              q            = "avg:aws.ecs.service.cpuutilization.maximum{servicename:${var.service_worker},$env}"
              style {
                line_type  = "dotted"
                line_width = "thin"
                palette    = "grey"
              }
            }

            request {
              display_type = "line"
              q            = "avg:aws.ecs.service.cpuutilization.minimum{servicename:${var.service_worker},$env}"
              style {
                line_type  = "dotted"
                line_width = "thin"
                palette    = "grey"
              }
            }

            marker {
              display_type = "warning dashed"
              value        = "y = 80"
            }

            marker {
              display_type = "error dashed"
              value        = "y = 95"
            }

            yaxis {
              include_zero = true
              max          = "auto"
              min          = "auto"
              scale        = "linear"
            }
          }
        }

        # ECS – Memory usage
        widget {
          timeseries_definition {
            show_legend = true
            title       = "ECS – Memory usage"

            request {
              display_type = "line"
              q            = "avg:aws.ecs.service.memory_utilization{servicename:${var.service_worker},$env}"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "dog_classic"
              }
            }

            request {
              display_type = "line"
              q            = "avg:aws.ecs.service.memory_utilization.minimum{servicename:${var.service_worker},$env}"
              style {
                line_type  = "dotted"
                line_width = "thin"
                palette    = "grey"
              }
            }

            request {
              display_type = "line"
              q            = "avg:aws.ecs.service.memory_utilization.maximum{servicename:${var.service_worker},$env}"
              style {
                line_type  = "dotted"
                line_width = "thin"
                palette    = "grey"
              }
            }

            marker {
              display_type = "warning dashed"
              value        = "y = 80"
            }

            marker {
              display_type = "error dashed"
              value        = "y = 95"
            }

            yaxis {
              include_zero = true
              max          = "auto"
              min          = "auto"
              scale        = "linear"
            }
          }
        }

        # Number of tasks
        widget {
          timeseries_definition {
            show_legend = true
            title       = "Number of tasks"

            request {
              display_type = "line"
              q            = "max:aws.ecs.service.running{service:${var.service_worker},$env}"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "dog_classic"
              }
            }

            request {
              display_type = "line"
              q            = "max:aws.ecs.service.desired{service:${var.service_worker},$env}"
              style {
                line_type  = "dashed"
                line_width = "thin"
                palette    = "grey"
              }
            }

            yaxis {
              include_zero = true
              max          = "auto"
              min          = "auto"
              scale        = "linear"
            }
          }
        }

        # Event Loop Delay
        widget {
          timeseries_definition {
            show_legend = true
            title       = "Event Loop Delay"

            request {
              display_type = "line"
              q            = "(avg:nodejs.eventloop.delay.p99{service:${var.service_worker},$env}) * 1000"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "dog_classic"
              }
            }

            marker {
              display_type = "warning dashed"
              value        = "y = 100"
            }

            marker {
              display_type = "error dashed"
              value        = "y = 250"
            }

            yaxis {
              include_zero = true
              max          = "auto"
              min          = "auto"
              scale        = "linear"
            }
          }
        }
      }
    }
  }

  ##################################################
  # SQS Queues
  ##################################################
  dynamic "widget" {
    for_each = var.queues
    content {
      group_definition {
        title       = widget.value.title
        layout_type = "ordered"

        # Number of messages
        widget {
          timeseries_definition {
            show_legend = true
            title       = "Number of messages"
            request {
              display_type = "bars"
              q            = "avg:aws.sqs.number_of_messages_sent{queuename:${lower(widget.value.queue_name)},$env}.as_count()"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "dog_classic"
              }
            }
            yaxis {
              include_zero = true
              max          = "auto"
              min          = "auto"
              scale        = "linear"
            }
          }
        }

        # Number and age of messages
        widget {
          timeseries_definition {
            show_legend = true
            title       = "Number and age of messages"

            request {
              display_type = "bars"
              q            = "max:aws.sqs.approximate_number_of_messages_visible{queuename:${lower(widget.value.queue_name)},$env}.rollup(max)"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "orange"
              }
            }

            request {
              display_type = "line"
              q            = "avg:aws.sqs.approximate_age_of_oldest_message{queuename:${lower(widget.value.queue_name)},$env}"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "orange"
              }
            }

            yaxis {
              include_zero = true
              max          = "auto"
              min          = "auto"
              scale        = "linear"
            }
          }
        }

        # Number of messages in dead letter
        dynamic "widget" {
          for_each = widget.value.dlq_name == "" ? [] : [widget.value]
          content {
            query_value_definition {
              title = "Number of messages in dead letter"

              request {
                q          = "max:aws.sqs.approximate_number_of_messages_visible{queuename:${lower(widget.value.dlq_name)},$env}.rollup(max)"
                aggregator = "max"

                conditional_formats {
                  comparator = ">"
                  value      = "0"
                  palette    = "red_on_white"
                }

                conditional_formats {
                  comparator = "="
                  value      = "0"
                  palette    = "green_on_white"
                }
              }

              autoscale = true
              precision = 2

              timeseries_background {
                type = "area"

                yaxis {
                  include_zero = false
                }
              }
            }
          }
        }

        # Message size
        widget {
          timeseries_definition {
            show_legend = true
            title       = "Message size"

            request {
              display_type = "line"
              q            = "avg:aws.sqs.sent_message_size{queuename:${lower(widget.value.queue_name)},$env}"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "grey"
              }
            }

            yaxis {
              include_zero = true
              max          = "auto"
              min          = "auto"
              scale        = "linear"
            }
          }
        }
      }
    }
  }

  ##################################################
  # DynamoDB Tables
  ##################################################
  dynamic "widget" {
    for_each = var.dynamodb_tables
    content {
      group_definition {
        title       = "DynamoDB – ${widget.value.title}"
        layout_type = "ordered"

        # Errors and throttling
        widget {
          timeseries_definition {
            show_legend = true
            title       = "Errors and throttling"

            request {
              display_type = "bars"
              q            = "max:aws.dynamodb.user_errors{tablename:${lower(widget.value.table_name)},$env}.as_count()"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "orange"
              }
            }

            request {
              display_type = "bars"
              q            = "max:aws.dynamodb.system_errors{tablename:${lower(widget.value.table_name)},$env}.as_count()"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "red"
              }
            }

            request {
              display_type = "bars"
              q            = "max:aws.dynamodb.throttled_requests{tablename:${lower(widget.value.table_name)},$env}.as_count()"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "purple"
              }
            }

            marker {
              display_type = "warning dashed"
              value        = "y = 1"
            }

            marker {
              display_type = "error dashed"
              value        = "y = 10"
            }

            yaxis {
              include_zero = true
              max          = "auto"
              min          = "auto"
              scale        = "linear"
            }
          }
        }

        # Successful request latency
        widget {
          timeseries_definition {
            show_legend = true
            title       = "Successful request latency"

            request {
              display_type = "line"
              q            = "avg:aws.dynamodb.successful_request_latency{tablename:${lower(widget.value.table_name)},$env}"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "dog_classic"
              }
            }

            marker {
              display_type = "warning dashed"
              value        = "y = 25"
            }

            marker {
              display_type = "error dashed"
              value        = "y = 100"
            }

            yaxis {
              include_zero = true
              max          = "auto"
              min          = "auto"
              scale        = "linear"
            }
          }
        }

        # Read and write throughput
        widget {
          timeseries_definition {
            show_legend = true
            title       = "Read and write throughput"

            request {
              display_type = "bars"
              q            = "sum:aws.dynamodb.consumed_read_capacity_units{tablename:${lower(widget.value.table_name)},$env}.as_count()"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "dog_classic"
              }
            }

            request {
              display_type = "bars"
              q            = "sum:aws.dynamodb.consumed_write_capacity_units{tablename:${lower(widget.value.table_name)},$env}.as_count()"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "orange"
              }
            }

            yaxis {
              include_zero = true
              max          = "auto"
              min          = "auto"
              scale        = "linear"
            }
          }
        }

        # Item count
        widget {
          timeseries_definition {
            show_legend = true
            title       = "Item count"

            request {
              display_type = "line"
              q            = "avg:aws.dynamodb.item_count{tablename:${lower(widget.value.table_name)},$env}"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = "grey"
              }
            }

            yaxis {
              include_zero = true
              max          = "auto"
              min          = "auto"
              scale        = "linear"
            }
          }
        }
      }
    }
  }

  ##################################################
  # API Requests
  ##################################################
  dynamic "widget" {
    for_each = length(var.http_endpoints) > 0 ? [true] : []
    content {
      group_definition {
        title       = "API Requests"
        layout_type = "ordered"

        dynamic "widget" {
          for_each = local.http_endpoints
          content {
            timeseries_definition {
              show_legend = true
              title       = widget.value.title

              request {
                display_type = "bars"
                q            = "sum:fgr.http.server.request.count{${widget.value.metric_dims}}.as_rate().rollup(sum, 60)"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "dog_classic"
                }
              }

              request {
                display_type = "bars"
                q            = "sum:fgr.http.server.request.errors{${widget.value.metric_dims}}.as_rate().rollup(sum, 60)"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "dog_classic"
                }
              }

              request {
                display_type   = "line"
                on_right_yaxis = true
                q              = "(p99:fgr.http.server.request.duration{${widget.value.metric_dims}}) * 1000"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "orange"
                }
              }

              yaxis {
                include_zero = true
                max          = "auto"
                min          = "auto"
                scale        = "linear"
              }

              right_yaxis {
                include_zero = true
                max          = "auto"
                min          = "auto"
                scale        = "linear"
              }
            }
          }
        }
      }
    }
  }

  ##################################################
  # Events
  ##################################################
  dynamic "widget" {
    for_each = length(var.events) > 0 ? [true] : []
    content {
      group_definition {
        title       = "Events"
        layout_type = "ordered"

        dynamic "widget" {
          for_each = var.events
          content {
            timeseries_definition {
              show_legend = true
              title       = widget.value

              request {
                display_type = "bars"
                q            = "sum:fgr.message.consumer.count{service:${local.events_service},resource.name:${lower(widget.value)},$env}.as_count()"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "dog_classic"
                }
              }

              request {
                display_type = "bars"
                q            = "sum:fgr.message.consumer.errors{service:${local.events_service},resource.name:${lower(widget.value)},$env}.as_count()"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "dog_classic"
                }
              }

              request {
                display_type   = "line"
                on_right_yaxis = true
                q              = "(p95:fgr.message.consumer.duration{service:${local.events_service},resource.name:${lower(widget.value)},$env}) * 1000"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "orange"
                }
              }

              yaxis {
                include_zero = true
                max          = "auto"
                min          = "auto"
                scale        = "linear"
              }

              right_yaxis {
                include_zero = true
                max          = "auto"
                min          = "auto"
                scale        = "linear"
              }
            }
          }
        }
      }
    }
  }
}
