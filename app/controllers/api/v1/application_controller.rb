module API
  module V1
    class ApplicationController < ::ApplicationController
      before_action -> { skip_authorization }
      before_action :check_recruitment_cycle_is_current_or_next_year

      def authenticate
        authenticate_or_request_with_http_token do |token|
          ActiveSupport::SecurityUtils.secure_compare(token, Rails.application.config.authentication_token)
        end
      end

      def check_recruitment_cycle_is_current_or_next_year
        current_year = Settings.current_recruitment_cycle_year
        next_year = current_year + 1

        requested_year = params[:recruitment_year]
        is_next_or_current_year = [current_year, next_year]
          .map(&:to_s)
          .include?(requested_year)

        unless requested_year.nil? || is_next_or_current_year
          render json: { status: 400, message: "The specified recruitment cycle is not the current year, please use ?recruitment_year=#{current_year}" }.to_json, status: :bad_request
        end
      end
    end
  end
end
