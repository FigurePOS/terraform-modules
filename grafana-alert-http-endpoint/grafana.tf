resource "grafana_rule_group" "http" {
  for_each = local.rules

  name             = "${local.group_name}-${each.key}"
  folder_uid       = var.folder_uid
  interval_seconds = local.eval_interval_seconds

  rule {
    name           = each.value.name
    condition      = "C"
    for            = local.pending_for
    no_data_state  = "OK"
    exec_err_state = "KeepLast"
    is_paused      = false

    annotations = merge(local.panel_annotations, {
      summary     = each.value.summary
      description = each.value.description
    })

    labels = merge(local.rule_labels, {
      kind = each.value.kind
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
        maxDataPoints = local.max_data_points
        datasource = {
          type = "axiomhq-axiom-datasource"
          uid  = var.axiom_datasource_uid
        }
        kind    = "mpl"
        version = "2.0"
        totals  = false
        query   = each.value.query
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
              params = [each.value.threshold]
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
