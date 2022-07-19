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
