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
        user = provider.users.new
        @user_form = UserForm.new(current_user, user)
      end

      def create
        user = provider.users.new
        @user_form = UserForm.new(current_user, user, params: user_params)

        if @user_form.stash
          redirect_to check_support_provider_users_path
        else
          render(:new)
        end
      end

      def check
        user = provider.users.new
        @user_form = UserForm.new(current_user, user)
      end

    private

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
