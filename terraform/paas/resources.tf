resource cloudfoundry_app teacher-training-api {
  name         = var.app.name
  space        = data.cloudfoundry_space.space.id
  docker_image = var.docker_image
  strategy     = "blue-green-v2"

  service_binding {
    service_instance = cloudfoundry_service_instance.postgres.id
  }

  service_binding {
    service_instance = cloudfoundry_service_instance.redis.id
  }

  routes {
    route = cloudfoundry_route.teacher-training-api-route.id
  }

  environment = merge(var.app_env, local.app_secrets)
}

resource cloudfoundry_route teacher-training-api-route {
  domain   = data.cloudfoundry_domain.local.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.app.hostname
}

resource "cloudfoundry_service_instance" "postgres" {
  name         = var.paas_postgres_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans["small-11"]
  json_params  = "{\"enable_extensions\": [\"pg_buffercache\",\"pg_stat_statements\", \"plpgsql\"]}"
}

resource "cloudfoundry_service_instance" "redis" {
  name         = var.paas_redis_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans["tiny-5_x"]
  json_params  = "{\"maxmemory_policy\": \"allkeys-lfu\" }"
}
