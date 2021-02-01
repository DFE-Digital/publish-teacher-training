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

variable paas_app_config { type = map }

variable key_vault_name {}

variable key_vault_resource_group {}

variable key_vault_infra_secret_name {}

variable azure_credentials {}

variable statuscake_alerts {
  type    = map
  default = {}
}

locals {
  cf_api_url                     = "https://api.london.cloud.service.gov.uk"
  paas_app_secrets               = yamldecode(file(var.paas_app_secrets_file))
  paas_app_environment_variables = merge(local.paas_app_secrets, var.paas_app_config)
  docker_credentials = {
    username = local.infra_secrets.DOCKERHUB_USERNAME
    password = local.infra_secrets.DOCKERHUB_PASSWORD
  }
  azure_credentials = jsondecode(var.azure_credentials)
}
