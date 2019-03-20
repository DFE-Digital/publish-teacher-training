module API
  module V2
    class ApplicationController < ::ApplicationController
      attr_reader :current_user

      before_action :check_terms_accepted
      before_action :add_provider_count_header

      def authenticate
        authenticate_or_request_with_http_token do |token|
          email = email_from_token(token)

          @current_user = User.find_by("lower(email) = ?", email.downcase)

          @current_user.present?
        end
      end

    private

      def add_provider_count_header
        response.set_header('Provider-Count', Provider.count)
      end

      def check_terms_accepted
        return if @current_user&.accept_terms_date_utc.present?

        error_body = {
          errors: [
            {
              status: 403,
              title: 'Forbidden',
              detail: 'The user has not accepted terms and conditions.'
            }
          ]
        }
        render json: error_body, status: :forbidden
      end

      def email_from_token(token)
        if Settings.authentication.algorithm == 'plain-text'
          # This method can be used in development mode to simplify querying
          # the API with curl. It should allow us to do:
          #
          #    curl -H 'Authorization: Bearer user@education.gov.uk' http://localhost:3001/api/v2/providers
          token
        else
          (payload, _options) = JWT.decode(token,
                                               Settings.authentication.secret,
                                               Settings.authentication.algorithm)
          payload['email']
        end
      end
    end
  end
end
