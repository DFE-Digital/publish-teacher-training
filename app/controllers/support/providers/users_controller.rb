module Support
  module Providers
    class UsersController < SupportController
      def index
        @users = provider.users.order(:last_name).page(params[:page] || 1)
        render layout: "provider_record"
      end

      def show
        user
      end

      def delete
        user
      end

      def destroy
        UserAssociationsService::Delete.call(user:, providers: provider)
        flash[:success] = I18n.t("success.user_removed")
        redirect_to support_provider_users_path(provider)
      end

      def new
        @user_form = UserForm.new(current_user, user)
        @user_form.clear_stash
      end

      def create
        @user_form = UserForm.new(current_user, user, params: user_params)
        if @user_form.stash
          redirect_to support_provider_check_user_path
        else
          render(:new)
        end
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
        provider
        User.find_or_initialize_by(email: params.dig(:support_user_form, :email))
      end

      def user_params
        params.require(:support_user_form).permit(:first_name, :last_name, :email)
      end

      def provider
        @provider ||= Provider.find(params[:provider_id])
      end

      def user
        @user ||= provider.users.find(params[:id])
      end
    end
  end
end
