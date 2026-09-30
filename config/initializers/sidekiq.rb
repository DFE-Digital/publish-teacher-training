# frozen_string_literal: true

load_cron_jobs = lambda do
  if Settings.bg_jobs
    cron_jobs = SolidQueueCronHandoffWorker.wrap(Settings.bg_jobs.to_h)
    Sidekiq::Cron::Job.load_from_hash(cron_jobs)
  end
end

if ENV.key?("REDIS_WORKER_URL")
  Sidekiq.configure_server do |config|
    config.redis = {
      url: ENV.fetch("REDIS_WORKER_URL"),
    }
    config.logger.level = Logger::WARN

    config.on(:startup, &load_cron_jobs)
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

    config.on(:startup, &load_cron_jobs)
  end

end
