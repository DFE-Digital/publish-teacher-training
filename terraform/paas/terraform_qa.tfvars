app = {
  name               = "qa-teacher-training-api"
  docker_image       = "dfedigital/teacher-training-api:testr"
  hostname           = "qa-teacher-training-api"
  space              = "find-qa"
  paas_postgres_name = "teaching-training-api-qa-pg-svc"
  paas_redis_name    = "teaching-training-api-qa-redis-svc"
}

app_env = {
  RAILS_ENV                                        = "qa_paas"
  RAILS_SERVE_STATIC_FILES                         = true
  WEBSITE_SLOT_POLL_WORKER_FOR_CHANGE_NOTIFICATION = "0"
  SETTINGS__LOGSTASH__PORT                         = 22135
}
