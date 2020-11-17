variable cf_space {}

variable web_app_instances {}

variable web_app_memory {}

variable web_app_host_name {}

variable worker_app_instances {}

variable worker_app_memory {}

variable postgres_service_plan {}

variable redis_service_plan {}

variable docker_image {}

variable app_environment {}

variable app_environment_variables { type = map }

locals {
  web_app_name          = "teacher-training-api-${var.app_environment}"
  worker_app_name       = "teacher-training-api-worker-${var.app_environment}"
  postgres_service_name = "teacher-training-api-postgres-${var.app_environment}"
  redis_service_name    = "teacher-training-api-redis-${var.app_environment}"

  worker_app_start_command = "bundle exec sidekiq -c 5 -C config/sidekiq.yml"

  postgres_params = {
    enable_extensions = ["pg_buffercache", "pg_stat_statements", "btree_gin", "btree_gist"]
  }
  web_app_routes = [cloudfoundry_route.web_app_service_gov_uk_route, cloudfoundry_route.web_app_cloudapps_digital_route]
}
