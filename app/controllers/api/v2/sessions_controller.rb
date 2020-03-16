module API
  module V2
    class SessionsController < API::V2::ApplicationController
      include ValidateJsonapiType
      skip_before_action :check_terms_accepted, only: :create

      deserializable_resource :session

      def create
        skip_authorization

        @current_user.update(
          create_params.merge(
            last_login_date_utc: Time.now.utc,
          ),
        )

        record_first_login
        send_welcome_email

        render jsonapi: @current_user
      end

    private

      def create_params
        validate_jsonapi_type(params, "sessions")

        params
          .require(:session)
          .except(:id, :type)
          .permit(
            :first_name,
            :last_name,
          )
      end

      def record_first_login
        RecordFirstLoginService.new.execute(current_user: @current_user)
      end

      def send_welcome_email
        SendWelcomeJob.perform_later(current_user: @current_user)
      end
    end
  end
end
