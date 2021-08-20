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

variable docker_credentials {}

variable logstash_url {}

variable app_environment {}

variable app_environment_variables { type = map }

locals {
  app_name_suffix              = var.app_environment != "review" ? var.app_environment : "pr-${var.web_app_host_name}"
  web_app_name                 = "teacher-training-api-${local.app_name_suffix}"
  worker_app_name              = "teacher-training-api-worker-${local.app_name_suffix}"
  postgres_service_name        = "teacher-training-api-postgres-${local.app_name_suffix}"
  redis_service_name           = "teacher-training-api-redis-${local.app_name_suffix}"
  logging_service_name         = "teacher-training-api-logit-${local.app_name_suffix}"
  deployment_strategy          = "blue-green-v2"
  qa_postgres_service_instance = "eef01a89-0659-4eae-8220-8a142fa4502e"

  worker_app_start_command = "bundle exec sidekiq -c 5 -C config/sidekiq.yml"

  postgres_extensions = {
    enable_extensions = ["pg_stat_statements", "btree_gin", "btree_gist"]
  }
  postgres_params = local.postgres_extensions
  web_app_routes  = [cloudfoundry_route.web_app_service_gov_uk_route, cloudfoundry_route.web_app_cloudapps_digital_route]
}
