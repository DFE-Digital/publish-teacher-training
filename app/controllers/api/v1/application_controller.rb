module API
  module V1
    class ApplicationController < ::ApplicationController
      before_action -> { skip_authorization }

      def authenticate
        authenticate_or_request_with_http_token do |token|
          ActiveSupport::SecurityUtils.secure_compare(token, Rails.application.config.authentication_token)
        end
      end
    end
  end
end
