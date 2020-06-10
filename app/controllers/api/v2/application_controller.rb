module API
  module V2
    class ApplicationController < ::ApplicationController
      attr_reader :current_user

      rescue_from ActiveRecord::RecordNotFound, with: :jsonapi_404

      before_action :store_request_id
      before_action :check_user_is_kept
      before_action :check_terms_accepted

      def authenticate
        authenticate_or_request_with_http_token do |token|
          @current_user = AuthenticationService.new(logger: Rails.logger).execute(token)
          assign_sentry_contexts
          @current_user.present?
        end
      end

      def jsonapi_404
        render jsonapi: nil, status: :not_found
      end

    private

      def check_user_is_kept
        return if current_user&.kept?

        error_body = {
          errors: [
            {
              status: 403,
              title: "Forbidden",
              detail: "The user has been removed.",
            },
          ],
          meta: {
            error_type: :user_has_been_removed,
          },
        }
        render json: error_body, status: :forbidden
      end

      def check_terms_accepted
        return if current_user&.accept_terms_date_utc.present?

        error_body = {
          errors: [
            {
              status: 403,
              title: "Forbidden",
              detail: "The user has not accepted terms and conditions.",
            },
          ],
          meta: {
            error_type: :user_not_accepted_terms_and_conditions,
          },
        }
        render json: error_body, status: :forbidden
      end

      def assign_sentry_contexts
        Raven.user_context(id:              @current_user&.id)
        Raven.tags_context(sign_in_user_id: @current_user&.sign_in_user_id)
        Raven.extra_context(request_id: RequestStore.store[:request_id])
      end

      def append_info_to_payload(payload)
        super

        if current_user.present?
          payload[:user] = {
            id:         current_user.id,
            sign_in_id: current_user.sign_in_user_id,
          }
        end
        payload[:request_id] = RequestStore.store[:request_id]
      end

      def store_request_id
        RequestStore.store[:request_id] = request.uuid
      end
    end
  end
end
