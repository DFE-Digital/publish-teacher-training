# frozen_string_literal: true

module FeatureService
  class << self
    def require(feature_name)
      raise "Feature #{feature_name} is disabled" unless enabled?(feature_name)

      true
    end

    def enabled?(feature_name)
      return false if Settings.features.blank?

      segments = feature_name.to_s.split('.')

      segments.reduce(Settings.features) { |config, segment| config[segment] }
    end
  end
end
