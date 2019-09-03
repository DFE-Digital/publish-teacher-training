module API
  module System
    class ApplicationController < ::ApplicationController
      before_action -> { skip_authorization }

      def authenticate
        authenticate_or_request_with_http_token do |token|
          ActiveSupport::SecurityUtils.secure_compare(token, Rails.application.config.system_authentication_token)
        end
      end
    end
  end
end
