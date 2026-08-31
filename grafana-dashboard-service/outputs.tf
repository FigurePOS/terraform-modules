output "uid" {
  description = "Grafana dashboard UID (stable; use in alert panel links)."
  value       = local.dashboard_uid
}

output "http_panel_ids" {
  description = "Map of HTTP panel title (METHOD /route) to Grafana panel id. First http_endpoints entry is 100."
  value = {
    for i, ep in local.http_endpoints : ep.title => 100 + i
  }
}

output "event_panel_ids" {
  description = "Map of event name (var.events) to Grafana panel id. First events entry is 200."
  value = {
    for i, event in var.events : event => 200 + i
  }
}
