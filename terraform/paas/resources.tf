resource cloudfoundry_app teacher-training-api {
  name         = var.app.name
  space        = data.cloudfoundry_space.space.id
  docker_image = var.app.docker_image
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

  environment = {
#     APPINSIGHTS_INSTRUMENTATIONKEY                   = var.APPINSIGHTS_INSTRUMENTATIONKEY
    RAILS_ENV                                        = var.app_env.RAILS_ENV
    WEBSITE_SLOT_POLL_WORKER_FOR_CHANGE_NOTIFICATION = "0"
    SETTINGS__LOGSTASH__HOST                         = var.SETTINGS__LOGSTASH__HOST
    SETTINGS__LOGSTASH__PORT                         = var.app_env.SETTINGS__LOGSTASH__PORT
    RAILS_SERVE_STATIC_FILES                         = var.app_env.RAILS_SERVE_STATIC_FILES
  }
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
  json_params  = "{\"enable_extensions\": [\"postgis\"] }"
}

resource "cloudfoundry_service_instance" "redis" {
  name         = var.paas_redis_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans["tiny-5_x"]
  json_params  = "{\"maxmemory_policy\": \"allkeys-lfu\" }"
}

resource cloudfoundry_app ttapi-geocode-ci {
  name         = "teacher-training-bg-geocode"
  space        = data.cloudfoundry_space.space.id
  docker_image = "dfedigital/teacher-training-bg-geocode:1459624"
  strategy     = "blue-green-v2"

  service_binding {
    service_instance = cloudfoundry_service_instance.postgres.id
  }

  service_binding {
    service_instance = cloudfoundry_service_instance.redis.id
  }
  environment = {
    RAILS_ENV                                        = var.app_env.RAILS_ENV
    WEBSITE_SLOT_POLL_WORKER_FOR_CHANGE_NOTIFICATION = "0"
    SETTINGS__LOGSTASH__HOST                         = var.SETTINGS__LOGSTASH__HOST
    SETTINGS__LOGSTASH__PORT                         = var.app_env.SETTINGS__LOGSTASH__PORT
    RAILS_SERVE_STATIC_FILES                         = var.app_env.RAILS_SERVE_STATIC_FILES
  }
}
