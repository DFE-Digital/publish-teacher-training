module "redis_worker" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/redis?ref=testing"

  name = "worker"
  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
}

module "redis_cache" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/redis?ref=testing"

  name = "cache"
  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
}

resource "random_string" "postgres_username" {
  length  = 16
  special = false
  upper   = false
}

resource "random_password" "postgres_password" {
  length  = 12
  special = false
}

module "postgres" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/postgres?ref=aks-postgres"
#  source = "/Users/SNeal@ai.baesystems.com/github/DFE-Digital/terraform-modules/aks/postgres"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  /*   admin_username        = local.infra_secrets.POSTGRES_ADMIN_PASSWORD
  admin_password        = local.infra_secrets.POSTGRES_ADMIN_USERNAME */

# need to work out how to make this flip between the default for container postgres and
# the admin user for the postgres module
  admin_username = "postgres"
  admin_password = random_password.postgres_password.result

  use_azure = var.deploy_azure_backing_services
}
