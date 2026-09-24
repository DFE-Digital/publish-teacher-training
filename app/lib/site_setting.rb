# frozen_string_literal: true

require "./config/initializers/redis"

class SiteSetting
  def self.cycle_schedule
    # ENV["ENABLE_SWITCHER"] allows us to selecctively enable the switcher in
    # the test environemtn specifically so we can test this functionality
    return :real if Rails.env.test? && ENV["ENABLE_SWITCHER"].blank?

    RedisClient.current.get("cycle_schedule")&.to_sym || :real
  end

  # Whether the switcher forces the apply deadline banner on. It is a second
  # axis, not a phase, so it is stored and read separately from cycle_schedule.
  def self.deadline_banner?
    return false if Rails.env.test? && ENV["ENABLE_SWITCHER"].blank?

    RedisClient.current.get("deadline_banner") == "true"
  end

  def self.set(name:, value:)
    RedisClient.current.set(name, value)
  end
end
