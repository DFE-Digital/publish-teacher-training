module "application_configuration" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application_configuration?ref=aks-application-configuration"

  namespace             = var.namespace
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  key_vault_secret_name         = var.key_vault_app_secret_name

  secret_variables = {
    DATABASE_URL = module.postgres.url
    REDIS_URL    = module.redis_cache.url
  }
}

/* module "infrastructure_configuration" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application_configuration?ref=aks-application-configuration"

  namespace    = var.namespace
  environment  = local.environment
  service_name = local.service_name

  key_vault_name                = var.key_vault_name
  key_vault_resource_group_name = var.resource_group_name
  key_vault_secret_name         = var.key_vault_infra_secret_name
} */

module "web_application" {
  # source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=aks-application"
  source = "/Users/SNeal@ai.baesystems.com/github/DFE-Digital/terraform-modules/aks/application"

  is_web = true

  namespace    = var.namespace
  environment  = local.environment
  service_name = "${local.service_name}"

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image           = var.docker_image
  # command                = ["/bin/sh", "-c", "bundle exec rails db:migrate:with_data_migrations && bundle exec rails server -b 0.0.0.0"]
  command                = ["/bin/sh", "-c", "bundle exec rails db:setup && bundle exec rails server -b 0.0.0.0"]
  web_external_hostnames = ["ftt-review-7777.cluster3.development.teacherservices.cloud"]
  max_memory             = "512Mi"
  probe_path             = "/ping"
}

module "worker_application" {
  # source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=aks-application"
  source = "/Users/SNeal@ai.baesystems.com/github/DFE-Digital/terraform-modules/aks/application"

  name   = "worker"
  is_web = false

  namespace    = var.namespace
  environment  = local.environment
  service_name = "${local.service_name}"

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image = var.docker_image
  command      = ["/bin/sh", "-c", "bundle exec sidekiq -C config/sidekiq.yml"]
  # command      = ["/bin/sh", "-c 5", "bundle exec sidekiq -C config/sidekiq.yml"] failed
  # command      = ["/bin/sh", "bundle exec sidekiq -c 5 -C config/sidekiq.yml"]
  # command      = ["/bin/sh", "bundle exec sidekiq -c 5 -C config/sidekiq.yml"] failed
  max_memory = "512Mi"
  probe_command = ["pgrep", "-f", "sidekiq"]
}
