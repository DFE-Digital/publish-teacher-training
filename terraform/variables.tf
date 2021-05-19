variable cf_sso_passcode { default = null }

variable cf_space {}

variable paas_web_app_instances {}

variable paas_web_app_memory {}

variable paas_worker_app_instances {}

variable paas_worker_app_memory {}

variable paas_docker_image {}

variable paas_postgres_service_plan {}

variable paas_redis_service_plan {}

variable paas_app_environment {}

variable paas_web_app_host_name {}

variable paas_app_config_file { default = "./workspace_variables/app_config.yml" }

variable key_vault_name {}

variable key_vault_resource_group {}

variable key_vault_app_secret_name {}

variable key_vault_infra_secret_name {}

variable azure_credentials { default = null }

variable statuscake_alerts {
  type    = map
  default = {}
}

locals {
  cf_api_url                     = "https://api.london.cloud.service.gov.uk"
  app_config                     = yamldecode(file(var.paas_app_config_file))[var.paas_app_environment]
  app_secrets                    = yamldecode(data.azurerm_key_vault_secret.app_secrets.value)
  infra_secrets                  = yamldecode(data.azurerm_key_vault_secret.infra_secrets.value)
  paas_app_environment_variables = merge(local.app_secrets, local.app_config)
  docker_credentials = {
    username = local.infra_secrets.DOCKERHUB_USERNAME
    password = local.infra_secrets.DOCKERHUB_PASSWORD
  }
  azure_credentials = try(jsondecode(var.azure_credentials), null)
}
