terraform {
  required_version = "1.2.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.21.1"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.15.5"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.0.4"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
  subscription_id            = try(local.azure_credentials.subscriptionId, null)
  client_id                  = try(local.azure_credentials.clientId, null)
  client_secret              = try(local.azure_credentials.clientSecret, null)
  tenant_id                  = try(local.azure_credentials.tenantId, null)
}

provider "cloudfoundry" {
  api_url           = local.cf_api_url
  user              = var.cf_sso_passcode == "" ? local.infra_secrets.CF_USER : null
  password          = var.cf_sso_passcode == "" ? local.infra_secrets.CF_PASSWORD : null
  sso_passcode      = var.cf_sso_passcode != "" ? var.cf_sso_passcode : null
  store_tokens_path = var.cf_sso_passcode != "" ? ".cftoken" : null
}

provider "statuscake" {
  api_token   = local.infra_secrets.STATUSCAKE_PASSWORD
}

module "paas" {
  source = "./modules/paas"

  cf_space                       = var.cf_space
  app_environment                = var.paas_app_environment
  docker_image                   = var.paas_docker_image
  logstash_url                   = local.infra_secrets.LOGSTASH_URL
  web_app_host_name              = var.paas_web_app_host_name
  web_app_memory                 = var.paas_web_app_memory
  web_app_instances              = var.paas_web_app_instances
  worker_app_instances           = var.paas_worker_app_instances
  worker_app_memory              = var.paas_worker_app_memory
  web_app_stopped                = var.paas_web_app_stopped
  worker_app_stopped             = var.paas_worker_app_stopped
  postgres_service_plan          = var.paas_postgres_service_plan
  redis_service_plan             = var.paas_redis_service_plan
  app_environment_variables      = local.paas_app_environment_variables
  publish_gov_uk_host_names      = var.publish_gov_uk_host_names
  find_gov_uk_host_names         = var.find_gov_uk_host_names
  restore_from_db_guid           = var.paas_restore_from_db_guid
  db_backup_before_point_in_time = var.paas_db_backup_before_point_in_time
  enable_external_logging        = var.paas_enable_external_logging
}

module "statuscake" {
  source = "./modules/statuscake"

  alerts = var.statuscake_alerts
}
