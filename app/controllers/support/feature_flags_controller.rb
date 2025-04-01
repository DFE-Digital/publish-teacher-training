# frozen_string_literal: true

module Support
  class FeatureFlagsController < ApplicationController
    def update
      FeatureFlag.send(action, feature_name)

      if Rails.env.production?
        SlackNotificationJob.perform_now(
          ":flags: Feature ‘#{feature_name}‘ was #{action}d",
          support_feature_flags_path,
        )
      end

      redirect_to support_feature_flags_path, flash: { success: "Feature ‘#{feature_name.humanize}’ #{action}d" }
    end

  private

    def action
      params[:state]
    end

    def feature_name
      params[:feature_name]
    end
  end
end
