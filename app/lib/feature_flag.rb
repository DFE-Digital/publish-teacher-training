# frozen_string_literal: true

class FeatureFlag
  extend Rails.application.routes.url_helpers

  class << self
    def active?(feature_name)
      feature = RedisClient.current.get("feature_flags_#{feature_name}")

      return false unless feature

      JSON.parse(feature)["state"]
    end

    def activate(feature_name)
      raise UnknownFeatureError unless feature_name.in?(features)

      sync_with_redis(feature_name, true)
      notify_slack(feature_name, true)
    end

    def deactivate(feature_name)
      raise UnknownFeatureError unless feature_name.in?(features)

      sync_with_redis(feature_name, false)
      notify_slack(feature_name, false)
    end

    def features
      FeatureFlags.all.to_h { |name, description, owner|
        [name, FeatureFlag.new(name:, description:, owner:)]
      }.with_indifferent_access
    end

    def last_updated(feature_name)
      feature = RedisClient.current.get("feature_flags_#{feature_name}")

      return unless feature

      JSON.parse(feature)["updated_at"]
    end

  private

    def sync_with_redis(feature_name, feature_state)
      RedisClient.current.set(
        "feature_flags_#{feature_name}", { state: feature_state, updated_at: Time.zone.now }.to_json
      )
    end

    def notify_slack(feature_name, feature_activated)
      return unless Rails.env.production?

      SlackNotificationJob.perform_later(
        I18n.t(slack_notification_i18n_key(feature_activated), feature_name: feature_name.humanize),
        Rails.application.routes.url_helpers.support_feature_flags_path,
      )
    end

    def slack_notification_i18n_key(feature_activated)
      "feature_flags.slack_notification.#{feature_activated ? 'activated' : 'deactivated'}"
    end
  end

  attr_accessor :name, :description, :owner, :type

  def initialize(name:, description:, owner:)
    self.name = name
    self.description = description
    self.owner = owner
  end

  class UnknownFeatureError < StandardError; end
end
