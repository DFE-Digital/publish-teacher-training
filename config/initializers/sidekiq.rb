if ENV.key?("VCAP_SERVICES")
  Sidekiq.configure_server do |config|
    config.redis = {
      url: ENV.fetch("REDIS_WORKER_URL"),
    }

    if Settings.bg_jobs
      Sidekiq::Cron::Job.load_from_hash Settings.bg_jobs
    end
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

    if Settings.bg_jobs
      Sidekiq::Cron::Job.load_from_hash Settings.bg_jobs
    end
  end

end
