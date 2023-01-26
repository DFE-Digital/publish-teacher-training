# frozen_string_literal: true

if ENV.key?("VCAP_SERVICES")
  Sidekiq.configure_server do |config|
    config.redis = {
      url: ENV.fetch("REDIS_WORKER_URL")
    }
    config.logger.level = Logger::WARN

    Sidekiq::Cron::Job.load_from_hash Settings.bg_jobs if Settings.bg_jobs
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: ENV.fetch("REDIS_WORKER_URL")
    }
  end

else

  Sidekiq.configure_client do |config|
    config.redis = {
      password: Settings.mcbg.redis_password
    }
  end

  Sidekiq.configure_server do |config|
    config.redis = {
      password: Settings.mcbg.redis_password
    }

    Sidekiq::Cron::Job.load_from_hash Settings.bg_jobs if Settings.bg_jobs
  end

end
