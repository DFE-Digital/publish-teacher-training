# frozen_string_literal: true

class RedisSetting
  attr_reader :config

  def initialize(config = nil)
    @config = {
      url: ENV["REDIS_URL"],
    }.merge(parse_config(config))
  end

  def url
    config[:url]
  end

private

  def parse_config(config)
    service_config = JSON.parse(config.presence || "{}")
    redis_config = service_config["redis"]
    redis_cache_config = redis_config&.select { |r| r["instance_name"].include?("cache") }&.first

    return {} if redis_cache_config.nil?

    redis_credentials = redis_cache_config["credentials"]
    { url: redis_credentials["uri"] }
  end
end

class RedisClient
  def self.current
    @current ||= Redis.new(url: RedisSetting.new(ENV["VCAP_SERVICES"]).url)
  end
end
