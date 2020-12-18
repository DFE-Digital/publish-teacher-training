#PaaS
cf_space                   = "bat-qa"
paas_web_app_instances     = 1
paas_web_app_memory        = 512
paas_worker_app_instances  = 1
paas_worker_app_memory     = 512
paas_postgres_service_plan = "tiny-unencrypted-11"
paas_redis_service_plan    = "tiny-5_x"

paas_app_config = {
  RAILS_ENV                = "review"
  RAILS_SERVE_STATIC_FILES = true
}
