variable cf_space {}

variable web_app_instances {}

variable web_app_memory {}

variable web_app_host_name {}

variable worker_app_instances {}

variable worker_app_memory {}

variable web_app_stopped { default = false }

variable worker_app_stopped { default = false }

variable postgres_service_plan {}

variable redis_service_plan {}

variable docker_image {}

variable logstash_url {}

variable app_environment {}

variable app_environment_variables { type = map }

variable "publish_gov_uk_host_names" {
  default = []
  type = list
}

variable "find_gov_uk_host_names" {
  default = []
  type = list
}

variable "restore_from_db_guid" {}

variable "db_backup_before_point_in_time" {}

variable "enable_external_logging" {}
locals {
  app_name_suffix              = var.app_environment != "review" ? var.app_environment : "pr-${var.web_app_host_name}"
  web_app_name                 = "publish-teacher-training-${local.app_name_suffix}"
  publish_app_name             = "publish-${local.app_name_suffix}"
  cloudapp_names               = [local.web_app_name, local.publish_app_name]
  worker_app_name              = "publish-teacher-training-worker-${local.app_name_suffix}"
  postgres_service_name        = "publish-teacher-training-postgres-${local.app_name_suffix}"
  redis_worker_service_name    = "publish-teacher-training-worker-redis-${local.app_name_suffix}"
  redis_cache_service_name     = "publish-teacher-training-cache-redis-${local.app_name_suffix}"
  logging_service_name         = "publish-teacher-training-logit-${local.app_name_suffix}"
  deployment_strategy          = "blue-green-v2"
# This is the guid of the QA postgres database and is used in review app db creation
# It must be updated within 35 days if the QA db is recreated,
# as that is how long automated snapshots are kept
  qa_postgres_service_instance = "6ee1518e-5a3c-4d08-abe4-6847ff7919b0"

  worker_app_start_command = "bundle exec sidekiq -c 5 -C config/sidekiq.yml"

  app_environment_variables = merge(var.app_environment_variables,
    {
      DATABASE_URL     = cloudfoundry_service_key.postgres_key.credentials.uri
      REDIS_CACHE_URL  = cloudfoundry_service_key.redis_cache_key.credentials.uri
      REDIS_WORKER_URL = cloudfoundry_service_key.redis_worker_key.credentials.uri
    }
  )

  postgres_backup_restore_params = var.restore_from_db_guid != "" && var.db_backup_before_point_in_time != "" ? {
    restore_from_point_in_time_of     = var.restore_from_db_guid
    restore_from_point_in_time_before = var.db_backup_before_point_in_time
  } : {}
  postgres_extensions = {
    enable_extensions = ["pg_buffercache", "pg_stat_statements", "btree_gin", "btree_gist"]
  }
  review_app_postgres_params = {
    restore_from_latest_snapshot_of = local.qa_postgres_service_instance
  }
  postgres_params = merge(local.postgres_backup_restore_params, local.postgres_extensions, var.app_environment == "review" ? local.review_app_postgres_params : {})

  web_app_routes = flatten([
    values(cloudfoundry_route.web_app_cloudapps_digital_route),
    cloudfoundry_route.web_app_service_gov_uk_route,
    values(cloudfoundry_route.web_app_publish_gov_uk_route),
    values(cloudfoundry_route.web_app_find_gov_uk_route)
  ])

  logging_service_bindings = var.enable_external_logging ? [cloudfoundry_user_provided_service.logging.id] : []
}
