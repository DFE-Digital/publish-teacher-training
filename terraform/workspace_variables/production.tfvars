#PaaS
cf_space                   = "bat-prod"
paas_app_environment       = "prod"
paas_web_app_instances     = 2
paas_web_app_memory        = 512
paas_worker_app_instances  = 2
paas_worker_app_memory     = 512
paas_postgres_service_plan = "small-11"
paas_redis_service_plan    = "tiny-5_x"
paas_app_config = {
  RAILS_ENV                = "production"
  RAILS_SERVE_STATIC_FILES = true
  SETTINGS__LOGSTASH__PORT = 22135
}

#StatusCake
statuscake_alerts = {
  ttapi = {
    website_name  = "teacher-training-api-prod"
    website_url   = "https://api.publish-teacher-training-courses.service.gov.uk/ping"
    test_type     = "HTTP"
    check_rate    = 60
    contact_group = [151103]
    trigger_rate  = 0
    custom_header = "{\"Content-Type\": \"application/x-www-form-urlencoded\"}"
    status_codes  = "204, 205, 206, 303, 400, 401, 403, 404, 405, 406, 408, 410, 413, 444, 429, 494, 495, 496, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 521, 522, 523, 524, 520, 598, 599"
  }
}
