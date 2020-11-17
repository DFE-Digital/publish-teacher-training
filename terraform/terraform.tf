terraform {
  required_version = "~> 0.13.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.29.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.12.6"
    }
    statuscake = {
      source  = "terraform-providers/statuscake"
      version = "1.0.0"
    }
  }
  backend "azurerm" {
  }
}

provider cloudfoundry {
  api_url      = local.cf_api_url
  user         = var.cf_user
  password     = var.cf_user_password
  sso_passcode = var.cf_sso_passcode
}

provider statuscake {
  username = var.statuscake_username
  apikey   = var.statuscake_password
}

module paas {
  source = "./modules/paas"

  cf_space                  = var.cf_space
  app_environment           = var.paas_app_environment
  docker_image              = var.paas_docker_image
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
