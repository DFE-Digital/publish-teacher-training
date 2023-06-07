module "redis_worker" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/redis?ref=main"

  name                  = "worker"
  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = var.service_name
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
  azure_maxmemory_policy  = "noeviction"
}

module "redis_cache" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/redis?ref=main"

  name                  = "cache"
  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = var.service_name
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
}

module "postgres" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/postgres?ref=main"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = var.service_name
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure        = var.deploy_azure_backing_services
  azure_extensions = local.postgres_extensions
}
