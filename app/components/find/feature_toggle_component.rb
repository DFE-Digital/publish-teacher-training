module Find
  class FeatureToggleComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :feature_name

    def initialize(feature_name:)
      super
      @feature_name = feature_name
    end

    def toggle_label
      FeatureFlag.active?(feature_name) ? "Deactivate" : "Activate"
    end

    def toggle_link
      if FeatureFlag.active?(feature_name)
        find_feature_flags_path(feature_name:, state: :deactivate)
      else
        find_feature_flags_path(feature_name:, state: :activate)
      end
    end

    def toggle_aria_label
      "#{toggle_label} ‘#{feature_name}’ feature"
    end
  end
end
