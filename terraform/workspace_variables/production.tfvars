#PaaS
cf_space                   = "bat-prod"
paas_app_environment       = "prod"
paas_web_app_host_name     = null
paas_web_app_instances     = 2
paas_web_app_memory        = 512
paas_worker_app_instances  = 2
paas_worker_app_memory     = 512
paas_postgres_service_plan = "small-11"
paas_redis_service_plan    = "tiny-5_x"
paas_app_config = {
  RAILS_ENV                = "production"
  RAILS_SERVE_STATIC_FILES = true
}

#StatusCake
statuscake_alerts = {
  ttapi = {
    website_name   = "teacher-training-api-prod"
    website_url    = "https://api.publish-teacher-training-courses.service.gov.uk/ping"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [151103]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
  }
}
