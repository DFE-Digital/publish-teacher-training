module API
  module V2
    class SessionsController < API::V2::ApplicationController
      include ValidateJsonapiType
      skip_before_action :check_terms_accepted, only: %i[create create_by_magic]

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

      def create_by_magic
        skip_authorization

        params.require(:magic_link_token)
        if params[:magic_link_token] != @current_user.magic_link_token
          return render status: :forbidden
        end

        magic_link_token_age = Time.zone.now - @current_user.magic_link_token_sent_at
        if magic_link_token_age > Settings.magic_link.max_token_age.seconds
          return render status: :bad_request
        end

        @current_user.update(
          last_login_date_utc: Time.now.utc,
          magic_link_token: nil,
          magic_link_token_sent_at: nil,
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
        SendWelcomeEmailService.call(current_user: @current_user)
      end
    end
  end
end
