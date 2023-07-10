module "application_configuration" {
  source = "./vendor/modules/aks//aks/application_configuration"

  namespace             = var.namespace
  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  secret_yaml_key       = var.key_vault_app_secret_name
  secret_variables      = local.app_secrets
  config_variables      = local.app_env_values
}

module "web_application" {
  for_each = var.main_app

  source = "./vendor/modules/aks//aks/application"

  is_web = true

  namespace    = var.namespace
  environment  = local.app_name_suffix
  service_name = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image           = var.docker_image
  command                = var.use_db_setup_command ? local.db_setup_command : []
  web_external_hostnames = var.app_environment == "review" ? local.review_additional_hostnames : var.additional_hostnames
  max_memory             = each.value.max_memory
  replicas               = each.value.replicas
  probe_path             = "/ping"
}

module "worker_application" {
  for_each = var.worker_apps

  source = "./vendor/modules/aks//aks/application"

  name   = "worker"
  is_web = false

  namespace    = var.namespace
  environment  = local.app_name_suffix
  service_name = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image  = var.docker_image
  command       = length("${each.value.startup_command}") > 0 ? each.value.startup_command : local.worker_startup_command
  max_memory    = each.value.max_memory
  replicas      = each.value.replicas
  probe_command = ["pgrep", "-f", "sidekiq"]
}
