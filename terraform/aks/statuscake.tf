module "statuscake" {
  count = var.enable_monitoring ? 1 : 0

  source = "./vendor/modules/aks//monitoring/statuscake"

  uptime_urls = compact(concat(
  [for app in module.web_application : app.probe_url],
  local.statuscake_additional_hostnames
  ))
  ssl_urls    = var.apex_urls

  contact_groups = var.statuscake_contact_groups
}
