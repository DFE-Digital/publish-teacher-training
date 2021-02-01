#PaaS
cf_space                   = "bat-qa"
paas_app_environment       = "qa"
paas_web_app_host_name     = "qa"
paas_web_app_instances     = 1
paas_web_app_memory        = 512
paas_worker_app_instances  = 1
paas_worker_app_memory     = 512
paas_postgres_service_plan = "small-11"
paas_redis_service_plan    = "tiny-5_x"

paas_app_config = {
  RAILS_ENV                = "qa_paas"
  RAILS_SERVE_STATIC_FILES = true
}

# KeyVault
key_vault_name              = "s121d01-shared-kv-01"
key_vault_resource_group    = "s121d01-shared-rg"
key_vault_app_secret_name   = "TTAPI-APP-SECRETS-QA"
key_vault_infra_secret_name = "BAT-INFRA-SECRETS-QA"

# StatusCake
statuscake_alerts = {
  ttapi = {
    website_name   = "teacher-training-api-qa"
    website_url    = "https://qa.api.publish-teacher-training-courses.service.gov.uk/ping"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [188603]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
  }
}
