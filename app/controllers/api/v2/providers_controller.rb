module API
  module V2
    class ProvidersController < API::V2::ApplicationController
      before_action :get_user, if: -> { params[:user_id].present? }

      def index
        authorize Provider
        providers = policy_scope(Provider)
        providers = providers.where(id: @user.providers) if @user.present?

        render jsonapi: providers.in_order
      end

      def show
        provider = Provider.friendly.find(params[:code])
        authorize provider, :show?

        render jsonapi: provider
      end

    private

      def get_user
        @user = User.find(params[:user_id])
      end
    end
  end
end
