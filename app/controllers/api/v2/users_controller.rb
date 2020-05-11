module API
  module V2
    class UsersController < API::V2::ApplicationController
      before_action :build_user, except: :generate_and_send_magic_link
      deserializable_resource :user, only: :update
      skip_before_action :check_terms_accepted, only: :accept_terms

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

      def accept_transition_screen
        if @user.state == "new"
          @user.accept_transition_screen!
        end
      end

      def accept_terms
        @user.accept_terms_date_utc = Time.zone.now
        @user.save
      end

      def accept_rollover_screen
        if @user.state == "transitioned"
          @user.accept_rollover_screen!
        end
      end

      def generate_and_send_magic_link
        skip_authorization

        GenerateAndSendMagicLinkService.call(user: current_user)
      end

    private

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
            :accept_terms_date_utc,
          )
      end
    end
  end
end
