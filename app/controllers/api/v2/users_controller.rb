module API
  module V2
    class UsersController < API::V2::ApplicationController
      before_action :build_user, except: :generate_and_send_magic_link
      deserializable_resource :user, only: :update
      skip_before_action :check_terms_accepted, only: %i[accept_terms generate_and_send_magic_link]
      skip_before_action :authenticate, only: :generate_and_send_magic_link
      skip_before_action :check_user_is_kept, only: :generate_and_send_magic_link

      def show
        render jsonapi: @user,
               include: params[:includes]
      end

      def update
        if @user.update(user_params)
          render jsonapi: @user
        else
          render jsonapi_errors: @user.errors, status: :unprocessable_entity
        end
      end

      def accept_terms
        @user.accept_terms_date_utc = Time.zone.now

        if @user.save
          render jsonapi: @user
        else
          render jsonapi_errors: @user.errors, status: :unprocessable_entity
        end
      end

      def generate_and_send_magic_link
        skip_authorization

        user = User.where(email: email_from_token).first

        if user
          GenerateAndSendMagicLinkService.call(user: user)
        else
          NotificationService::UnrecognisedEmail.call(email: email_from_token)
        end
      end

    private

      def email_from_token
        @email_from_token ||= authenticate_or_request_with_http_token do |token|
          decoded_token = JWT.decode(
            token,
            Settings.authentication.secret,
            Settings.authentication.algorithm,
            )
          (decoded_token_payload, _algorithm) = decoded_token
          decoded_token_payload["email"]
        end
      end

      def build_user
        @user = authorize User.find(params[:id])
      end

      def user_params
        params
          .require(:user)
          .except(:id, :type, :admin, :organisations_id, :organisations_type)
          .permit(
            :email,
            :first_name,
            :last_name,
            :first_login_date_utc,
            :last_login_date_utc,
            :sign_in_user_id,
            :welcome_email_date_utc,
            :invite_date_utc,
            :state,
            :accept_terms_date_utc,
          )
      end
    end
  end
end
