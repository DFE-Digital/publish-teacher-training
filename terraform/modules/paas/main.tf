resource cloudfoundry_app web_app {
  name                       = local.web_app_name
  space                      = data.cloudfoundry_space.space.id
  health_check_type          = "http"
  health_check_http_endpoint = "/ping"
  instances                  = var.web_app_instances
  memory                     = var.web_app_memory
  docker_image               = var.docker_image
  strategy                   = local.deployment_strategy
  timeout                    = 180
  environment                = var.app_environment_variables
  docker_credentials         = var.docker_credentials

  service_binding {
    service_instance = cloudfoundry_service_instance.postgres.id
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.redis.id
  }
  dynamic "routes" {
    for_each = local.web_app_routes
    content {
      route = routes.value.id
    }
  }
}

resource cloudfoundry_app worker_app {
  name                 = local.worker_app_name
  space                = data.cloudfoundry_space.space.id
  health_check_type    = "process"
  instances            = var.worker_app_instances
  memory               = var.worker_app_memory
  docker_image         = var.docker_image
  strategy             = local.deployment_strategy
  command              = local.worker_app_start_command
  timeout              = 180
  health_check_timeout = 180
  environment          = var.app_environment_variables
  docker_credentials   = var.docker_credentials

  service_binding {
    service_instance = cloudfoundry_service_instance.postgres.id
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.redis.id
  }
}

resource cloudfoundry_route web_app_cloudapps_digital_route {
  domain   = data.cloudfoundry_domain.london_cloudapps_digital.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.web_app_name
}

resource cloudfoundry_route web_app_service_gov_uk_route {
  domain   = data.cloudfoundry_domain.api_publish_service_gov_uk.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.web_app_host_name
}

resource cloudfoundry_service_instance postgres {
  name         = local.postgres_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_service_plan]
  json_params  = jsonencode(local.postgres_params)
}

resource cloudfoundry_service_instance redis {
  name         = local.redis_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.redis_service_plan]
}
