#PaaS
cf_space                   = "bat-qa"
paas_app_environment       = "review"
paas_web_app_stopped       = true
paas_worker_app_stopped    = true
paas_web_app_instances     = 1
paas_web_app_memory        = 512
paas_worker_app_instances  = 1
paas_worker_app_memory     = 512
paas_postgres_service_plan = "tiny-unencrypted-11"
paas_redis_service_plan    = "micro-5_x"

# KeyVault
key_vault_resource_group = "s121d01-shared-rg"
