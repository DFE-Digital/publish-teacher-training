# frozen_string_literal: true

class RedisClient
  def self.current
    @current ||= Redis.new(url: ENV.fetch("REDIS_WORKER_URL", nil))
  end
end
