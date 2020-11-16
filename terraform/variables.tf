variable cf_user { default = null }

variable cf_user_password { default = null }

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

variable paas_app_config { type = map }

variable paas_app_secrets_file { default = "workspace_variables/app_secrets.yml" }

variable statuscake_alerts { type = map }

variable statuscake_username {}

variable statuscake_password {}

locals {
  cf_api_url                     = "https://api.london.cloud.service.gov.uk"
  paas_app_secrets               = yamldecode(file(var.paas_app_secrets_file))
  paas_app_environment_variables = merge(local.paas_app_secrets, var.paas_app_config)
}
