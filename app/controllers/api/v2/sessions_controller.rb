module API
  module V2
    class SessionsController < API::V2::ApplicationController
      include ValidateJsonapiType

      deserializable_resource :session

      def create
        skip_authorization

        @current_user.update(
          create_params.merge(
            last_login_date_utc: Time.now.utc
          )
        )

        send_welcome_email

        render jsonapi: @current_user
      end

    private

      def create_params
        validate_jsonapi_type(params, 'sessions')

        params
          .require(:session)
          .except(:id, :type)
          .permit(
            :first_name,
            :last_name
          )
      end

      def send_welcome_email
        welcome_email_service = SendWelcomeEmailService.new(mailer: WelcomeEmailMailer)
        welcome_email_service.execute(current_user: @current_user)
      end
    end
  end
end
