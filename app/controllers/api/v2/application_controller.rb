module API
  module V2
    class ApplicationController < ::ApplicationController
      attr_reader :current_user

      rescue_from ActiveRecord::RecordNotFound, with: :jsonapi_404

      before_action :check_terms_accepted

      def authenticate
        authenticate_or_request_with_http_token do |token|
          @current_user = AuthenticationService.call(token)
          assign_sentry_contexts
          @current_user.present?
        end
      end

      def jsonapi_404
        render jsonapi: nil, status: :not_found
      end

    private

      def check_terms_accepted
        return if @current_user&.accept_terms_date_utc.present?

        error_body = {
          errors: [
            {
              status: 403,
              title: 'Forbidden',
              detail: 'The user has not accepted terms and conditions.'
            }
          ],
          meta: {
            error_type: :user_not_accepted_terms_and_conditions
          }
        }
        render json: error_body, status: :forbidden
      end

      def assign_sentry_contexts
        Raven.user_context(id:              @current_user&.id)
        Raven.tags_context(sign_in_user_id: @current_user&.sign_in_user_id)
      end
    end
  end
end
