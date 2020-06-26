if Rails.env.qa_paas?
  service_config = JSON.parse(ENV["VCAP_SERVICES"])
  redis_config = service_config["redis"].first
  redis_credentials = redis_config["credentials"]

  Sidekiq.configure_server do |config|
    config.redis = {
      url: redis_credentials["uri"],
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: redis_credentials["uri"],
    }
  end
end

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
