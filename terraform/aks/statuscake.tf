module "statuscake" {
  count = var.enable_monitoring ? 1 : 0

  source = "./vendor/modules/aks//monitoring/statuscake"

  uptime_urls = compact(concat([module.web_application["main"].probe_url], local.statuscake_additional_hostnames))
  ssl_urls    = compact(local.statuscake_additional_hostnames)

  contact_groups = var.statuscake_contact_groups
}
