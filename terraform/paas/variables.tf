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

variable "paas_postgres_name" {
  default = "dfe-teacher-services-find-pg-svc"
}

variable "paas_redis_name" {
  default = "dfe-teacher-services-find-redis-svc"
}
