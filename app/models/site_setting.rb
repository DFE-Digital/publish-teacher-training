require "./config/initializers/redis"

class SiteSetting < ApplicationRecord
  def self.cycle_schedule
    Redis.current.get("cycle_schedule")&.to_sym || :real
  end

  def self.set(name:, value:)
    Redis.current.set(name, value)
  end
end
