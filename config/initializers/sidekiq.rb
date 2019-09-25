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
