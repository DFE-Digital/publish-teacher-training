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
        provider
        @user = User.new
      end

    private

      def provider
        @provider ||= Provider.find(params[:provider_id])
      end

      def user
        @user ||= provider.users.find(params[:id])
      end
    end
  end
end
