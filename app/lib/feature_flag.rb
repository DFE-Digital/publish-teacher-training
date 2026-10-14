# frozen_string_literal: true

class FeatureFlag
  extend Rails.application.routes.url_helpers

  class << self
    def active?(feature_name)
      feature_state(feature_name)&.active || false
    end

    def activate(feature_name)
      raise UnknownFeatureError unless feature_name.in?(features)

      update_state(feature_name, true)
    end

    def deactivate(feature_name)
      raise UnknownFeatureError unless feature_name.in?(features)

      update_state(feature_name, false)
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
      feature_state(feature_name)&.updated_at
    end

  private

    def update_state(feature_name, active)
      state = FeatureFlagState.find_or_initialize_by(name: feature_name.to_s)
      state.assign_attributes(active:, updated_at: Time.zone.now)

      FeatureFlagState.transaction do
        state.save!
        LegacyRedisState.write_feature_flag(state.name, active: state.active, updated_at: state.updated_at)
      end

      Current.feature_flags&.store(state.name, state)
    end

    # Pages check many flags, so load them all in one query per request.
    def feature_state(feature_name)
      Current.feature_flags ||= FeatureFlagState.all.index_by(&:name)
      Current.feature_flags[feature_name.to_s]
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
