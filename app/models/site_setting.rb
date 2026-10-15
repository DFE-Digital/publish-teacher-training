# frozen_string_literal: true

class SiteSetting < ApplicationRecord
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
    name = name.to_s
    value = value.to_s

    setting = LegacyRedisState.with_state_lock do
      record = transaction do
        stored_setting = find_or_create_by!(name:) { |new_record| new_record.value = value }
        unless stored_setting.previously_new_record?
          stored_setting.update!(value:, legacy_redis_synced_at: nil)
        end
        stored_setting
      end

      LegacyRedisState.mirror_site_setting(record)
      record
    end

    Current.site_settings&.store(name, setting.value)
  end

  def self.cached_values
    Current.site_settings ||= pluck(:name, :value).to_h
  end

  private_class_method :cached_values
end
