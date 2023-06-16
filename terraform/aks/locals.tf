locals {
  app_name_suffix             = var.app_name == null ? var.app_environment : "${var.app_environment}-${var.app_name}"
  review_additional_hostnames = var.app_environment == "review" ? ["find-${local.app_name_suffix}.${var.cluster}.teacherservices.cloud"] : ["find-${local.app_name_suffix}.${var.cluster}.development.teacherservices.cloud"]
  db_setup_command            = ["/bin/sh", "-c", "bundle exec rails db:setup && bundle exec rails server -b 0.0.0.0"]
  worker_startup_command      = ["/bin/sh", "-c", "bundle exec sidekiq -c 5 -C config/sidekiq.yml"]
  postgres_extensions         = ["PG_BUFFERCACHE","PG_STAT_STATEMENTS", "BTREE_GIN", "BTREE_GIST", "CITEXT", "PLPGSQL", "UUID-OSSP", "POSTGIS"]
  app_secrets = {
    DATABASE_URL     = module.postgres.url
    REDIS_CACHE_URL  = module.redis_cache.url
    REDIS_WORKER_URL = module.redis_worker.url
  }
}
