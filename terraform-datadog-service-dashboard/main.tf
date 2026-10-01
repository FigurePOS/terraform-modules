resource "datadog_dashboard" "service_dashboard" {
  title       = var.service_name_readable
  layout_type = "ordered"
  template_variable {
    name    = "env"
    prefix  = "env"
    default = "production"
  }
  # Application
  widget {
    group_definition {
      title       = "Application"
      layout_type = "ordered"
      widget {
        timeseries_definition {
          show_legend = false
          title       = "ECS - CPU Usage"
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
          yaxis {
            include_zero = true
            max          = "auto"
            min          = "auto"
            scale        = "linear"
          }
        }
      }
      widget {
        timeseries_definition {
          show_legend = false
          title       = "CPU Usage"
          request {
            display_type = "line"
            q            = "avg:runtime.node.cpu.user{service:${var.service},$env}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "avg:runtime.node.cpu.system{service:${var.service},$env}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            formula {
              formula_expression = "query1 + query2"
            }

            display_type = "line"
            query {
              metric_query {
                query       = "avg:runtime.node.cpu.user{service:${var.service},$env}"
                data_source = "metrics"
                name        = "query1"
              }
            }

            query {
              metric_query {
                query       = "avg:runtime.node.cpu.system{service:${var.service},$env}"
                data_source = "metrics"
                name        = "query2"
              }
            }
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
      widget {
        timeseries_definition {
          show_legend = false
          title       = "ECS - Memory Usage"
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
            q            = "avg:aws.ecs.service.memory_utilization.maximum{servicename:${var.service},$env}"
            style {
              line_type  = "dotted"
              line_width = "thin"
              palette    = "grey"
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
          yaxis {
            include_zero = true
            max          = "auto"
            min          = "auto"
            scale        = "linear"
          }
        }
      }
      widget {
        timeseries_definition {
          show_legend = false
          title       = "Memory Usage"
          request {
            display_type = "line"
            q            = "avg:runtime.node.mem.rss{service:${var.service},$env}"
            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "avg:runtime.node.mem.heap_used{service:${var.service},$env}"
            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "avg:runtime.node.mem.heap_total{service:${var.service},$env}"
            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "avg:runtime.node.mem.external{service:${var.service},$env}"

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
      widget {
        timeseries_definition {
          show_legend = false
          title       = "Number of tasks"
          request {
            display_type = "line"
            q            = "sum:aws.ecs.service.running{service:${var.service},$env}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "sum:aws.ecs.service.desired{service:${var.service},$env}"

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
      widget {
        timeseries_definition {
          show_legend = false
          title       = "Event Loop Iterations Per Second"
          request {
            display_type = "line"
            q            = "avg:runtime.node.event_loop.delay.count{service:${var.service},$env}"

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
    }
  }
  # SQS
  dynamic "widget" {
    for_each = var.queue_name == "" && var.dead_letter_queue_name == "" ? [] : [true]
    content {
      group_definition {
        title       = "SQS Queue"
        layout_type = "ordered"
        dynamic "widget" {
          for_each = var.queue_name == "" ? [] : [true]
          content {
            timeseries_definition {
              show_legend = false
              title       = "Number of messages"
              request {
                display_type = "bars"
                q            = "sum:aws.sqs.number_of_messages_sent{queuename:${lower(var.queue_name)},$env}.as_count()"
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
        }
        dynamic "widget" {
          for_each = var.queue_name == "" ? [] : [true]
          content {
            timeseries_definition {
              show_legend = false
              title       = "Number and age of messages"
              request {
                display_type = "bars"
                q            = "max:aws.sqs.approximate_number_of_messages_visible{queuename:${lower(var.queue_name)},$env}.rollup(max)"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "orange"
                }
              }
              request {
                display_type = "line"
                q            = "max:aws.sqs.approximate_age_of_oldest_message{queuename:${lower(var.queue_name)},$env}"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "orange"
                }
                on_right_yaxis = true
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
        dynamic "widget" {
          for_each = var.dead_letter_queue_name == "" ? [] : [true]
          content {
            timeseries_definition {
              show_legend = false
              title       = "Number of messages in dead letter"
              request {
                display_type = "bars"
                q            = "sum:aws.sqs.approximate_number_of_messages_visible{queuename:${lower(var.dead_letter_queue_name)},$env}.rollup(max)"
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
        dynamic "widget" {
          for_each = var.queue_name == "" ? [] : [true]
          content {
            timeseries_definition {
              show_legend = false
              title       = "Message size"
              request {
                display_type = "line"
                q            = "avg:aws.sqs.sent_message_size{queuename:${lower(var.queue_name)},$env}"
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
        dynamic "widget" {
          for_each = var.queue_name == "" ? [] : [true]
          content {
            timeseries_definition {
              show_legend = false
              title       = "Number of messages waiting & processing in app queue"
              request {
                display_type = "line"
                q            = "max:figure.message.consumer.processing{$env,service:${var.service}*,consumer:main}.rollup(max)"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "dog_classic"
                }
              }
              request {
                display_type = "line"
                q            = "max:figure.message.consumer.waiting{$env,service:${var.service}*,consumer:main}.rollup(max)"
                style {
                  line_type  = "dotted"
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
        }
      }
    }
  }
  # Load Balancer
  widget {
    group_definition {
      title       = "Load Balancer"
      layout_type = "ordered"
      dynamic "widget" {
        for_each = [
          {
            code    = "2xx"
            palette = "dog_classic"
          },
          {
            code    = "3xx"
            palette = "dog_classic"
          },
          {
            code    = "4xx"
            palette = "warm"
          },
          {
            code    = "5xx"
            palette = "warm"
          },
        ]
        content {
          timeseries_definition {
            show_legend = false
            title       = "${widget.value.code} responses"
            request {
              display_type = "bars"
              q            = "sum:aws.applicationelb.httpcode_target_${widget.value.code}{targetgroup:targetgroup/${var.service}*,$env}.as_count()"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = widget.value.palette
              }
            }
            yaxis {
              include_zero = true
              max          = "auto"
              scale        = "linear"
              min          = "auto"
            }
          }
        }
      }
    }
  }
  # HTTP Endpoints
  dynamic "widget" {
    for_each = length(var.http_endpoints) > 0 ? [true] : []
    content {
      group_definition {
        title       = "HTTP Endpoints"
        layout_type = "ordered"
        dynamic "widget" {
          for_each = var.http_endpoints
          content {
            timeseries_definition {
              show_legend = false
              title       = widget.value.title
              request {
                display_type = "bars"
                q            = "sum:trace.express.request.hits{$env,service:${var.service},resource_name:${widget.value.endpoint}}.as_count()"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "dog_classic"
                }
              }
              request {
                display_type = "bars"
                q            = "sum:trace.express.request.errors{$env,service:${var.service},resource_name:${widget.value.endpoint}}.as_count()"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "red"
                }
              }
              request {
                display_type = "line"
                q            = "sum:trace.express.request{$env,service:${var.service},resource_name:${widget.value.endpoint}}.as_count()"
                style {
                  line_type  = "dotted"
                  line_width = "normal"
                  palette    = "red"
                }
                on_right_yaxis = true
              }
              yaxis {
                include_zero = true
                max          = "auto"
                scale        = "linear"
                min          = "auto"
              }
              right_yaxis {
                include_zero = true
                max          = "auto"
                scale        = "linear"
                min          = "auto"
              }
            }
          }
        }
      }
    }
  }
  # Events
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
              show_legend = false
              title       = widget.value
              request {
                display_type = "bars"
                q            = "sum:trace.figure.message.consumer.hits{$env,service:${var.service},resource_name:${lower(widget.value)}}.as_count()"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "dog_classic"
                }
              }
              request {
                display_type = "line"
                q            = "p95:trace.figure.message.consumer{$env,service:${var.service},resource_name:${lower(widget.value)}}.as_count()"
                style {
                  line_type  = "dotted"
                  line_width = "normal"
                  palette    = "warm"
                }
                on_right_yaxis = true
              }
              yaxis {
                include_zero = true
                max          = "auto"
                scale        = "linear"
                min          = "auto"
              }
              right_yaxis {
                include_zero = true
                max          = "auto"
                scale        = "linear"
                min          = "auto"
              }
            }
          }
        }
      }
    }
  }
  # Ping latency
  widget {
    group_definition {
      title       = "Ping latency"
      layout_type = "ordered"
      widget {
        timeseries_definition {
          show_legend = false
          title       = "Ping latency"
          request {
            display_type = "line"
            q            = "max:trace.express.request{$env,service:${var.service},resource_name:get_${var.route_prefix}/ping}"
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
    }
  }
  # Dynamo
  dynamic "widget" {
    for_each = length(var.dynamo_tables) > 0 ? [true] : []
    content {
      group_definition {
        title       = "DynamoDB"
        layout_type = "ordered"
        dynamic "widget" {
          for_each = var.dynamo_tables
          content {
            timeseries_definition {
              show_legend = false
              title       = widget.value.title
              request {
                display_type = "line"
                q            = "avg:aws.dynamodb.successful_request_latency{tablename:${widget.value.table},$env}"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "dog_classic"
                }
              }
              request {
                display_type = "line"
                q            = "max:aws.dynamodb.item_count{tablename:${widget.value.table},$env}"
                style {
                  line_type  = "dotted"
                  line_width = "normal"
                  palette    = "grey"
                }
                on_right_yaxis = true
              }
              yaxis {
                include_zero = true
                max          = "auto"
                scale        = "linear"
                min          = "auto"
              }
              right_yaxis {
                include_zero = true
                max          = "auto"
                scale        = "linear"
                min          = "auto"
              }
            }
          }
        }
      }
    }
  }
}
