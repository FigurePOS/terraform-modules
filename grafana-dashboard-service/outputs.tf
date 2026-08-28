output "uid" {
  description = "Grafana dashboard UID (stable; use in alert panel links)."
  value       = local.dashboard_uid
}

output "http_panel_ids" {
  description = "Map of HTTP panel title (METHOD /route) to Grafana panel id. POST /payment/:id is 103 on the payments sample."
  value = {
    for i, ep in local.http_endpoints : ep.title => 100 + i
  }
}
