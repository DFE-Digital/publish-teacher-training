# frozen_string_literal: true

class RedisClient
  def self.current
    @current ||= Redis.new(url: ENV.fetch("REDIS_WORKER_URL", nil))
  end

  def self.cache
    @cache ||= Redis.new(url: ENV.fetch("REDIS_CACHE_URL") { ENV.fetch("REDIS_WORKER_URL", nil) })
  end
end
