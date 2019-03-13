module API
  module V2
    class ApplicationController < ::ApplicationController
      attr_reader :current_user

      def authenticate
        authenticate_or_request_with_http_token do |token|
          if Settings.authentication.algorithm == 'plain-text'
            # This method can be used in development mode to simplify querying
            # the API with curl. It should allow us to do:
            #
            #    curl -H 'Authorization: Bearer user@education.gov.uk' http://localhost:3001/api/v2/providers
            email = token
          else
            (payload, _options) = JWT.decode(token,
                                                 Settings.authentication.secret,
                                                 Settings.authentication.algorithm)
            email = payload['email']
          end
          # match email addresses case-insensitively
          @current_user = User.find_by("lower(email) = ?", email.downcase)
          @current_user.present?
        end
      end
    end
  end
end
