module Api
  module V2
    class ApplicationController < ::ApplicationController
      def authenticate
        authenticate_or_request_with_http_token do |token|
          if Settings.authentication.algorithm == 'plain-text'
            # This method can be used in development mode to simplify querying
            # the API with curl. It should allow us to do:
            #
            #    curl -H 'Authorization: Bearer user@education.gov.uk' http://localhost:3000/api/v2/providers
            email = token
          else
            (json_payload, options) = JWT.decode(token,
                                                 Settings.authentication.secret,
                                                 Settings.authentication.algorithm)
            payload = JSON.parse(json_payload)
            email = payload['email']
          end
          @user = User.find_by(email: email)
          @user.present?
        end
      end
    end
  end
end
