app = {
  name               = "qa-teacher-training-api"
  hostname           = "qa-teacher-training-api"
  space              = "find-qa"
  paas_postgres_name = "teaching-training-api-qa-pg-svc"
  paas_redis_name    = "teaching-training-api-qa-redis-svc"
}

app_env = {
  RAILS_ENV                                                       = "qa_paas"
  RAILS_SERVE_STATIC_FILES                                        = true
  WEBSITE_SLOT_POLL_WORKER_FOR_CHANGE_NOTIFICATION                = "0"
  SETTINGS__LOGSTASH__PORT                                        = 22135
  SETTINGS_GOVUK_NOTIFY_COURSE_PUBLISH_EMAIL_TEMPLATE_ID          = "c4944115-6e73-4b30-9bc2-bf784c0e9aaa"
  SETTING_SGOVUK_NOTIFY_COURSE_UPDATE_EMAIL_TEMPLATE_ID           = "ebd252cf-21b2-48b6-b00c-ab6493189001"
  SETTINGS_GOVUK_NOTIFY_COURSE_VACANCIES_FILLED_EMAIL_TEMPLATE_ID = "0a6058b7-62d1-41e7-a5a9-f4a13ef86cbe"
  SETTINGS_GOVUK_NOTIFY_COURSE_WITHDRAW_EMAIL_TEMPLATE_ID         = "f7fee829-f0e7-40d1-9bd7-299f673e8c24"
  SETTINGS_GOVUK_NOTIFY_MAGIC_LINK_EMAIL_TEMPLATE_ID              = "26a4c7f2-3caa-4770-8b2e-d7baf6342dd1"
  SETTINGS_GOVUK_NOTIFY_WELCOME_EMAIL_TEMPLATE_ID                 = "42a9723d-b5a1-413a-89e6-bbdd073373ab"

}
