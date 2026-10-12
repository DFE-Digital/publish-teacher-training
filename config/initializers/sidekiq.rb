# frozen_string_literal: true

# config/recurring.yml is the only schedule source. Sidekiq Cron entries persist
# in Redis, so clear them whenever Sidekiq boots while it drains legacy payloads.
clear_cron_jobs = -> { Sidekiq::Cron::Job.destroy_all! }

if ENV.key?("REDIS_WORKER_URL")
  Sidekiq.configure_server do |config|
    config.redis = {
      url: ENV.fetch("REDIS_WORKER_URL"),
    }
    config.logger.level = Logger::WARN

    config.on(:startup, &clear_cron_jobs)
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: ENV.fetch("REDIS_WORKER_URL"),
    }
  end

else

  Sidekiq.configure_client do |config|
    config.redis = {
      password: Settings.mcbg.redis_password,
    }
  end

  Sidekiq.configure_server do |config|
    config.redis = {
      password: Settings.mcbg.redis_password,
    }

    config.on(:startup, &clear_cron_jobs)
  end

end
