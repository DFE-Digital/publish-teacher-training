resource cloudfoundry_app web_app {
  name                       = local.web_app_name
  space                      = data.cloudfoundry_space.space.id
  health_check_type          = "http"
  health_check_http_endpoint = "/ping"
  instances                  = var.web_app_instances
  memory                     = var.web_app_memory
  disk_quota                 = 1500
  docker_image               = var.docker_image
  strategy                   = local.deployment_strategy
  timeout                    = 300
  stopped                    = var.web_app_stopped
  environment                = local.app_environment_variables

  service_binding {
    service_instance = cloudfoundry_service_instance.redis.id
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.redis_cache.id
  }

  dynamic "service_binding" {
    for_each = local.logging_service_bindings
    content {
      service_instance = service_binding.value
    }
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
  timeout              = 300
  health_check_timeout = 300
  stopped              = var.worker_app_stopped
  environment          = local.app_environment_variables

  service_binding {
    service_instance = cloudfoundry_service_instance.redis.id
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.redis_cache.id
  }

  dynamic "service_binding" {
    for_each = local.logging_service_bindings
    content {
      service_instance = service_binding.value
    }
  }
}

resource cloudfoundry_route web_app_cloudapps_digital_route {
  for_each = toset(local.cloudapp_names)
  domain   = data.cloudfoundry_domain.london_cloudapps_digital.id
  space    = data.cloudfoundry_space.space.id
  hostname = each.value
}

resource cloudfoundry_route web_app_service_gov_uk_route {
  domain   = data.cloudfoundry_domain.api_publish_service_gov_uk.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.web_app_host_name
}

resource cloudfoundry_route web_app_publish_gov_uk_route {
  for_each = toset(var.publish_gov_uk_host_names)
  domain   = data.cloudfoundry_domain.publish_service_gov_uk.id
  space    = data.cloudfoundry_space.space.id
  hostname = each.value
}

resource cloudfoundry_route web_app_find_gov_uk_route {
  for_each = toset(var.find_gov_uk_host_names)
  domain   = data.cloudfoundry_domain.find_service_gov_uk.id
  space    = data.cloudfoundry_space.space.id
  hostname = each.value
}

locals {
  target_app = var.find_route_target == "find" ? data.cloudfoundry_app.find_app.id : resource.cloudfoundry_app.web_app.id
}

resource cloudfoundry_route find_web_app_cloudapps_digital_route {
  count = var.find_route_target != null ? 1 : 0

  domain   = data.cloudfoundry_domain.london_cloudapps_digital.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.find_app_name

#  target {
#    app = local.target_app
#  }
}

resource cloudfoundry_route find_web_app_find_gov_uk_route {
  for_each = toset(var.find_app_gov_uk_host_names)
  domain   = data.cloudfoundry_domain.find_service_gov_uk.id
  space    = data.cloudfoundry_space.space.id
  hostname = each.value

#  target {
#    app = local.target_app
#  }
}

resource cloudfoundry_service_instance postgres {
  name         = local.postgres_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_service_plan]
  json_params  = jsonencode(local.postgres_params)
  timeouts {
    create = "60m"
    update = "60m"
  }
}

resource cloudfoundry_service_instance redis {
  name         = local.redis_worker_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.redis_service_plan]
  json_params  = jsonencode({ maxmemory_policy = "noeviction" })
  timeouts {
    create = "60m"
    update = "60m"
  }
}

resource cloudfoundry_service_instance redis_cache {
  name         = local.redis_cache_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.redis_service_plan]
  json_params  = jsonencode({ maxmemory_policy = "allkeys-lru" })
  timeouts {
    create = "60m"
    update = "60m"
  }
}

resource cloudfoundry_user_provided_service logging {
  name             = local.logging_service_name
  space            = data.cloudfoundry_space.space.id
  syslog_drain_url = var.logstash_url
}

resource cloudfoundry_service_key postgres_key {
  name             = "${local.postgres_service_name}-app-key"
  service_instance = cloudfoundry_service_instance.postgres.id
}

resource cloudfoundry_service_key redis_cache_key {
  name             = "${local.redis_cache_service_name}-key"
  service_instance = cloudfoundry_service_instance.redis_cache.id
}

resource cloudfoundry_service_key redis_worker_key {
  name             = "${local.redis_worker_service_name}-key"
  service_instance = cloudfoundry_service_instance.redis.id
}
