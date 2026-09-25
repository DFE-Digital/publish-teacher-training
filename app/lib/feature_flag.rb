# frozen_string_literal: true

class FeatureFlag
  extend Rails.application.routes.url_helpers

  class << self
    def active?(feature_name)
      feature = feature_data(feature_name)

      return false unless feature

      feature["state"]
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

    def candidate_authentication_active?
      active?(:candidate_accounts) || active?(:require_authentication_for_find_results)
    end

    def last_updated(feature_name)
      feature = feature_data(feature_name)

      return unless feature

      feature["updated_at"]
    end

  private

    def sync_with_redis(feature_name, feature_state)
      feature = { state: feature_state, updated_at: Time.zone.now }.to_json

      RedisClient.current.set("feature_flags_#{feature_name}", feature)

      Current.feature_flags ||= {}
      Current.feature_flags[feature_name.to_s] = JSON.parse(feature)
    end

    def feature_data(feature_name)
      cache_key = feature_name.to_s
      Current.feature_flags ||= {}

      Current.feature_flags.fetch(cache_key) do
        feature = RedisClient.current.get("feature_flags_#{feature_name}")

        Current.feature_flags[cache_key] = feature && JSON.parse(feature)
      end
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
