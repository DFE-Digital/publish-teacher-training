terraform {
  required_version = "~> 0.13.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.45.1"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.13.0"
    }
    statuscake = {
      source  = "terraform-providers/statuscake"
      version = "1.0.0"
    }
  }
  backend azurerm {
  }
}

provider azurerm {
  features {}

  skip_provider_registration = true
  subscription_id            = try(local.azure_credentials.subscriptionId, null)
  client_id                  = try(local.azure_credentials.clientId, null)
  client_secret              = try(local.azure_credentials.clientSecret, null)
  tenant_id                  = try(local.azure_credentials.tenantId, null)
}

provider cloudfoundry {
  api_url      = local.cf_api_url
  user         = local.infra_secrets.CF_USER
  password     = local.infra_secrets.CF_PASSWORD
  sso_passcode = var.cf_sso_passcode
}

provider statuscake {
  username = local.infra_secrets.STATUSCAKE_USERNAME
  apikey   = local.infra_secrets.STATUSCAKE_PASSWORD
}

module paas {
  source = "./modules/paas"

  cf_space                  = var.cf_space
  app_environment           = var.paas_app_environment
  docker_image              = var.paas_docker_image
  docker_credentials        = local.docker_credentials
  logstash_url              = local.infra_secrets.LOGSTASH_URL
  web_app_host_name         = var.paas_web_app_host_name
  web_app_memory            = var.paas_web_app_memory
  web_app_instances         = var.paas_web_app_instances
  worker_app_instances      = var.paas_worker_app_instances
  worker_app_memory         = var.paas_worker_app_memory
  postgres_service_plan     = var.paas_postgres_service_plan
  redis_service_plan        = var.paas_redis_service_plan
  app_environment_variables = local.paas_app_environment_variables
}

module statuscake {
  source = "./modules/statuscake"

  alerts = var.statuscake_alerts
}
