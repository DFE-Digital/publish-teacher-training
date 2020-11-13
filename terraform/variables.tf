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

variable SECRET_KEY_BASE {}

variable SENTRY_DSN {}

variable LOGSTASH_HOST {}

variable GOVUK_NOTIFY_API_KEY {}

variable statuscake_alerts { type = map }

variable statuscake_username {}

variable statuscake_password {}

locals {
  cf_api_url = "https://api.london.cloud.service.gov.uk"
  paas_app_secrets = {
    SETTINGS__LOGSTASH__HOST        = var.LOGSTASH_HOST
    SECRET_KEY_BASE                 = var.SECRET_KEY_BASE
    SENTRY_DSN                      = var.SENTRY_DSN
    SETTINGS__GOVUK_NOTIFY__API_KEY = var.GOVUK_NOTIFY_API_KEY
  }
  paas_app_environment_variables = merge(local.paas_app_secrets, var.paas_app_config)
}
