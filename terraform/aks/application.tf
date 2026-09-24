module "application_configuration" {
  source = "./vendor/modules/aks//aks/application_configuration"

  namespace             = var.namespace
  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
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
  enable_logit           = var.enable_logit
  run_as_non_root        = var.run_as_non_root
  command                = var.use_db_setup_command ? local.db_setup_command : []
  web_external_hostnames = var.app_environment == "review" ? local.review_additional_hostnames : var.additional_hostnames
  max_memory             = each.value.max_memory
  replicas               = each.value.replicas
  probe_path             = "/ping"

  send_traffic_to_maintenance_page = var.send_traffic_to_maintenance_page
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

  docker_image    = var.docker_image
  command         = length("${each.value.startup_command}") > 0 ? each.value.startup_command : local.worker_startup_command
  max_memory      = each.value.max_memory
  replicas        = each.value.replicas
  enable_logit    = var.enable_logit
  run_as_non_root = var.run_as_non_root
  probe_command = ["pgrep", "-f", "sidekiq"]

  enable_gcp_wif = true
}

module "solid_queue_worker" {
  source     = "./vendor/modules/aks//aks/application"
  depends_on = [module.web_application]

  name   = "solid-queue-worker"
  is_web = false

  namespace    = var.namespace
  environment  = local.app_name_suffix
  service_name = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image = var.docker_image
  # Shared ConfigMap sets RAILS_MAX_THREADS=50 for web. Override the DB pool only
  # for this process so each Solid Queue fork does not open a 50-connection pool.
  # Keep this >= sum of (threads × processes) across workers in config/queue.yml
  # (DEFAULT_QUEUE_THREADS etc.) or Solid Queue will warn and contend on the pool.
  command = [
    "/bin/sh",
    "-c",
    # $${...} so Terraform leaves the shell default for DATABASE_CONNECTION_POOL_SIZE alone.
    # start_when_ready waits for migrate/db:setup/restore so we never cache a missing PK.
    "DATABASE_CONNECTION_POOL_SIZE=$${DATABASE_CONNECTION_POOL_SIZE:-5} bundle exec rake solid_queue:start_when_ready",
  ]
  max_memory      = var.solid_queue_worker_memory_max
  replicas        = var.solid_queue_worker_replicas
  enable_logit    = var.enable_logit
  run_as_non_root = var.run_as_non_root
  # Match rake solid_queue:start(_when_ready) during boot and forked processes (`.` matches `_`).
  probe_command = ["pgrep", "-f", "solid.queue"]

  enable_gcp_wif = true
}
