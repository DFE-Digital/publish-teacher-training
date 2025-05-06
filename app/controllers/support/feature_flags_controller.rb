# frozen_string_literal: true

module Support
  class FeatureFlagsController < ApplicationController
    rescue_from FeatureFlag::UnknownFeatureError, with: :unknown_feature

    def activate
      FeatureFlag.activate(feature_name)

      redirect_to support_feature_flags_path, flash: { success: t(".success", feature_name: feature_name.humanize) }
    end

    def deactivate
      FeatureFlag.deactivate(feature_name)

      redirect_to support_feature_flags_path, flash: { success: t(".success", feature_name: feature_name.humanize) }
    end

  private

    def unknown_feature
      redirect_to support_feature_flags_path, flash: { error: { message: t(".error.unknown_feature") } }
    end

    def feature_name
      params[:feature_name]
    end
  end
end
