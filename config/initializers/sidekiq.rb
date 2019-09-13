Sidekiq.configure_client do |config|
  config.redis = {
    password: Settings.mcbg.redis_password
  }
end
