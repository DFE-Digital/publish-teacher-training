locals {
  app_name_suffix             = var.app_name == null ? var.app_environment : "${var.app_environment}-${var.app_name}"
  review_additional_hostnames = var.app_environment == "review" ? ["find-${local.app_name_suffix}.${var.cluster}.teacherservices.cloud", "publish-${local.app_name_suffix}-api.${var.cluster}.teacherservices.cloud" ] : ["find-${local.app_name_suffix}.${var.cluster}.development.teacherservices.cloud"]
  db_setup_command            = ["/bin/sh", "-c", "bundle exec rails db:setup && bundle exec rails server -b 0.0.0.0"]
  worker_startup_command      = ["/bin/sh", "-c", "bundle exec sidekiq -c 5 -C config/sidekiq.yml"]
  postgres_extensions         = ["PG_BUFFERCACHE", "PG_STAT_STATEMENTS", "BTREE_GIN", "BTREE_GIST", "CITEXT", "UUID-OSSP", "POSTGIS"]
  app_secrets = merge(
    {
      DATABASE_URL     = module.postgres.url
      REDIS_CACHE_URL  = module.redis_cache.url
      REDIS_WORKER_URL = module.redis_worker.url
    },
    {
      AIRBYTE_CONFIGURATION = var.airbyte_enabled ? jsonencode({
        SOURCE_ID      = module.airbyte[0].airbyte_source_id
        DESTINATION_ID = module.airbyte[0].airbyte_destination_id
        CONNECTION_ID  = module.airbyte[0].airbyte_connection_id
     }) : null
    }
  )

  app_env_values = merge(
    yamldecode(file(var.app_config_file))[var.app_environment],
    { APP_NAME_SUFFIX = local.app_name_suffix },
    {
      BIGQUERY_AIRBYTE_DATASET                    = var.airbyte_enabled ? local.gcp_dataset_name : null
      AIRBYTE_SERVER_URL                          = var.airbyte_enabled ? "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}" : null
      BIGQUERY_HIDDEN_POLICY_TAG                  = var.airbyte_enabled ? "projects/rugged-abacus-218110/locations/europe-west2/taxonomies/69524444121704657/policyTags/6523652585511281766" : null
      AIRBYTE_INTERNAL_DATASET                    = var.airbyte_enabled ? "${local.gcp_dataset_name}_internal" : null
    }
  )
  # infra_secrets  = yamldecode(module.secrets.map[var.key_vault_infra_secret_name])
  app_resource_group_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"

  statuscake_additional_hostnames = var.additional_hostnames != null ? tolist([for hostname in var.additional_hostnames : format("https://%s/ping", hostname)]) : null
}
