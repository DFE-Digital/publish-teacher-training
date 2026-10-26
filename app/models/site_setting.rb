# frozen_string_literal: true

class SiteSetting < ApplicationRecord
  # Dropped in this release. Keep ignoring it until that migration has run
  # in every environment, then remove this line.
  self.ignored_columns += %w[legacy_redis_synced_at]

  NAMES = %w[cycle_schedule deadline_banner].freeze

  validates :name, inclusion: { in: NAMES }
  validates :value, presence: true

  def self.cycle_schedule
    # ENV["ENABLE_SWITCHER"] allows us to selectively enable the switcher in
    # the test environment specifically so we can test this functionality
    return :real if Rails.env.test? && ENV["ENABLE_SWITCHER"].blank?

    cached_values["cycle_schedule"]&.to_sym || :real
  end

  # Whether the switcher forces the apply deadline banner on. It is a second
  # axis, not a phase, so it is stored and read separately from cycle_schedule.
  def self.deadline_banner?
    return false if Rails.env.test? && ENV["ENABLE_SWITCHER"].blank?

    cached_values["deadline_banner"] == "true"
  end

  def self.set(name:, value:)
    setting = find_or_initialize_by(name: name.to_s)
    setting.update!(value: value.to_s)
    Current.site_settings&.store(setting.name, setting.value)
  end

  def self.cached_values
    Current.site_settings ||= pluck(:name, :value).to_h
  end

  private_class_method :cached_values
end
