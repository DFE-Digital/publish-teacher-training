module Find
  class FeatureFlagsController < ApplicationController
    before_action :enforce_basic_auth
    skip_before_action :redirect_to_maintenance_page_if_flag_is_active

    def index; end

    def update
      FeatureFlag.send(action, feature_name)

      if Rails.env.production?
        SlackNotificationJob.perform_now(
          ":flags: Feature ‘#{feature_name}‘ was #{action}d",
          find_feature_flags_path,
        )
      end

      flash[:success] = "Feature ‘#{feature_name.humanize}’ #{action}d"
      redirect_to find_feature_flags_path
    end

  private

    def enforce_basic_auth
      authenticate_or_request_with_http_basic do |username, password|
        BasicAuthenticable.authenticate(username, password)
      end
    end

    def action
      params[:state]
    end

    def feature_name
      params[:feature_name]
    end
  end
end
