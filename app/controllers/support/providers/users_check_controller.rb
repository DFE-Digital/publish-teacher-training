module Support
  module Providers
    class UsersCheckController < SupportController
      def show
        provider
        @user_form = UserForm.new(current_user, user)
      end

      def update
        @user_form = UserForm.new(current_user, user)
        if @user_form.save!
          UserAssociationsService::Create.call(user: @user_form.model, provider:) if @user_form.model.providers.exclude?(provider)
          redirect_to support_provider_users_path
          flash[:success] = "User added"
        end
      end

    private

      def user
        User.find_or_initialize_by(email: params.dig(:support_user_form, :email))
      end

      def provider
        @provider ||= Provider.find(params[:provider_id])
      end
    end
  end
end
