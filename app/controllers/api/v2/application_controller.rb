module API
  module V2
    class ApplicationController < ::ApplicationController
      attr_reader :current_user

      SERIALIZABLE_CLASSES = {
        User: API::V2::UserSerializable,
        Course: API::V2::CourseSerializable,
      }.freeze

      def authenticate
        authenticate_or_request_with_http_token do |token|
          if Settings.authentication.algorithm == 'plain-text'
            # This method can be used in development mode to simplify querying
            # the API with curl. It should allow us to do:
            #
            #    curl -H 'Authorization: Bearer user@education.gov.uk' http://localhost:3000/api/v2/providers
            email = token
          else
            (json_payload, _options) = JWT.decode(token,
                                                 Settings.authentication.secret,
                                                 Settings.authentication.algorithm)
            payload = JSON.parse(json_payload)
            email = payload['email']
          end
          @current_user = User.find_by(email: email)
          @current_user.present?
        end
      end
    end
  end
end
