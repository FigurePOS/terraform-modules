locals {
  # Transform http_endpoints from {method, route} to {title, endpoint}
  http_endpoints = [
    for e in var.http_endpoints : {
      title    = "${upper(e.method)} /${var.api_path_prefix}${e.route}"
      endpoint = "${lower(e.method)}_/${var.api_path_prefix}${e.route}"
    }
  ]
}

resource "datadog_dashboard" "service_dashboard" {
  title       = var.title
  layout_type = "ordered"

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
          show_legend = false
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
            q            = "max:aws.ecs.service.desired{service:${var.service},$env}"
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

      # Event Loop Utilization
      widget {
        timeseries_definition {
          show_legend = true
          title       = "Event Loop Utilization"

          request {
            display_type = "line"
            q            = "avg:nodejs.eventloop.utilization{service:${var.service},$env}"
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
            show_legend = false
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

        # Event Loop Utilization
        widget {
          timeseries_definition {
            show_legend = true
            title       = "Event Loop Utilization"

            request {
              display_type = "line"
              q            = "avg:nodejs.eventloop.utilization{service:${var.service_worker},$env}"
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
  }

  ##################################################
  # Load Balancer
  ##################################################
  widget {
    group_definition {
      title       = "Load Balancer"
      layout_type = "ordered"

      dynamic "widget" {
        for_each = [
          { code = "2xx", palette = "dog_classic" },
          { code = "3xx", palette = "dog_classic" },
          { code = "4xx", palette = "orange" },
          { code = "5xx", palette = "red" },
        ]
        content {
          timeseries_definition {
            show_legend = true
            title       = "${widget.value.code} responses"
            request {
              display_type = "bars"
              q            = "sum:aws.applicationelb.httpcode_target_${widget.value.code}{targetgroup:targetgroup/${var.service}/*,$env}.as_count()"
              style {
                line_type  = "solid"
                line_width = "normal"
                palette    = widget.value.palette
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
            timeseries_definition {
              show_legend = true
              title       = "Number of messages in dead letter"
              request {
                display_type = "bars"
                q            = "max:aws.sqs.approximate_number_of_messages_visible{queuename:${lower(widget.value.dlq_name)},$env}.rollup(max)"
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
  # APM – HTTP Endpoints
  ##################################################
  dynamic "widget" {
    for_each = length(var.http_endpoints) > 0 ? [true] : []
    content {
      group_definition {
        title       = "APM"
        layout_type = "ordered"

        dynamic "widget" {
          for_each = local.http_endpoints
          content {
            timeseries_definition {
              show_legend = true
              title       = widget.value.title

              # hits (OpenTelemetry – total requests)
              request {
                display_type = "bars"
                q            = "sum:trace.http.server.request.hits{service:${var.service},resource_name:${widget.value.endpoint},$env}.as_count()"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "dog_classic"
                }
              }

              # errors (4xx/5xx status codes)
              request {
                display_type = "bars"
                q            = "sum:trace.http.server.request.hits.by_http_status{service:${var.service},resource_name:${widget.value.endpoint},http.status_class:4xx,http.status_class:5xx,$env}.as_count()"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "dog_classic"
                }
              }

              # p99 latency
              request {
                display_type   = "line"
                on_right_yaxis = true
                q              = "p99:trace.http.server.request{service:${var.service},resource_name:${widget.value.endpoint},$env}"
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

              # count
              request {
                display_type = "bars"
                q            = "sum:trace.figure.message.consumer{service:${var.service}*,resource_name:${lower(widget.value)},$env}.as_count()"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "dog_classic"
                }
              }

              # 95th percentile duration
              request {
                display_type   = "line"
                on_right_yaxis = true
                q              = "p95:trace.figure.message.consumer{service:${var.service}*,resource_name:${lower(widget.value)},$env}"
                style {
                  line_type  = "solid"
                  line_width = "normal"
                  palette    = "warm"
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
  # Latency
  ##################################################
  widget {
    group_definition {
      title       = "API latency"
      layout_type = "ordered"

      # API
      widget {
        timeseries_definition {
          show_legend = true
          title       = "API latency"

          request {
            display_type = "line"
            q            = "max:trace.http.server.request{$env,resource_name:get,service:${var.service}}"
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
}


