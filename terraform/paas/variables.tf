variable docker_image {
  type    = string
  default = "dfedigital/teacher-training-api:paas-master"
}

variable app {
  type = map
}

variable app_env {
  type = map
}

variable api_url {
  type = string
}

variable user {
  type = string
}

variable password {
  type = string
}

variable SECRET_KEY_BASE {
  type = string
}

variable SENTRY_DSN {
  type = string
}

variable SETTINGS__LOGSTASH__HOST {
  type = string
}

variable timeout {
  type = number
  default = 360
}

variable SETTINGS__GOVUK_NOTIFY__API_KEY {
  type = string
}

variable "paas_postgres_name" {
  default = "dfe-teacher-services-find-pg-svc"
}

variable "paas_redis_name" {
  default = "dfe-teacher-services-find-redis-svc"
}

locals {
  app_secrets = {
    SETTINGS__LOGSTASH__HOST        = var.SETTINGS__LOGSTASH__HOST
    SECRET_KEY_BASE                 = var.SECRET_KEY_BASE
    SENTRY_DSN                      = var.SENTRY_DSN
    SETTINGS__GOVUK_NOTIFY__API_KEY = var.SETTINGS__GOVUK_NOTIFY__API_KEY
  }
}
