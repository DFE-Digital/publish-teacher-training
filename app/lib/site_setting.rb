# frozen_string_literal: true

require './config/initializers/redis'

class SiteSetting
  def self.cycle_schedule
    RedisClient.current.get('cycle_schedule')&.to_sym || :real
  end

  def self.set(name:, value:)
    RedisClient.current.set(name, value)
  end
end
