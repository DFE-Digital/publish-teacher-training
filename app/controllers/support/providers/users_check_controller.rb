module Support
  module Providers
    class UsersCheckController < SupportController
      def show
        @user_form = UserForm.new(current_user, user)
      end

    private

      def user
        provider
        User.find_or_initialize_by(email: params.dig(:support_user_form, :email))
      end

      def provider
        @provider ||= Provider.find(params[:provider_id])
      end
    end
  end
end
