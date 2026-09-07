resource "grafana_rule_group" "ratio" {
  name             = local.group_name
  folder_uid       = var.folder_uid
  interval_seconds = 60

  rule {
    name           = var.name
    condition      = "C"
    for            = "0s"
    no_data_state  = "OK"
    exec_err_state = "Error"
    is_paused      = false

    annotations = merge(local.panel_annotations, {
      summary     = local.summary
      description = "avg(last_${local.interval_m}m) of 100 * ${var.numerator_metric} / ${var.denominator_metric} > ${var.threshold}."
    })

    labels = merge(local.rule_labels, {
      kind = "metric-ratio"
    })

    data {
      ref_id         = "A"
      datasource_uid = var.axiom_datasource_uid

      relative_time_range {
        from = var.interval
        to   = 0
      }

      model = jsonencode({
        refId         = "A"
        hide          = false
        intervalMs    = 60000
        maxDataPoints = 43200
        datasource = {
          type = "axiomhq-axiom-datasource"
          uid  = var.axiom_datasource_uid
        }
        kind    = "mpl"
        version = "2.0"
        totals  = false
        query   = local.ratio_query
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        refId      = "B"
        type       = "reduce"
        expression = "A"
        reducer    = "mean"
        settings = {
          mode = "dropNN"
        }
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        refId      = "C"
        type       = "threshold"
        expression = "B"
        conditions = [
          {
            evaluator = {
              type   = "gt"
              params = [var.threshold]
            }
          },
        ]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
      })
    }
  }
}
