require "./config/initializers/redis"

class SiteSetting < ApplicationRecord
  def self.cycle_schedule
    Redis.new(url: RedisSetting.new(ENV.fetch("VCAP_SERVICES", nil)).url).get("cycle_schedule")&.to_sym || :real
  end

  def self.set(name:, value:)
    Redis.new(url: RedisSetting.new(ENV.fetch("VCAP_SERVICES", nil)).url).set(name, value)
  end
end
