#PaaS
cf_space                   = "bat-prod"
paas_app_environment       = "prod"
paas_web_app_host_name     = null
paas_web_app_instances     = 10
paas_web_app_memory        = 2048
paas_worker_app_instances  = 4
paas_worker_app_memory     = 512
paas_postgres_service_plan = "large-ha-11"
paas_redis_service_plan    = "micro-ha-5_x"
publish_gov_uk_host_names = ["www2"]

# KeyVault
key_vault_resource_group = "s121p01-shared-rg"

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
  ttapi_paas = {
    website_name   = "teacher-training-api-cloudapps-prod"
    website_url    = "https://teacher-training-api-prod.london.cloudapps.digital/ping"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [151103]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
  }
}
