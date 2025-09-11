# frozen_string_literal: true

require "./config/initializers/redis"

class SiteSetting
  def self.cycle_schedule
    # ENV["ENABLE_SWITCHER"] allows us to selecctively enable the switcher in
    # the test environemtn specifically so we can test this functionality
    return :real if Rails.env.test? && ENV["ENABLE_SWITCHER"].blank?

    RedisClient.current.get("cycle_schedule")&.to_sym || :real
  end

  def self.set(name:, value:)
    RedisClient.current.set(name, value)
  end
end
