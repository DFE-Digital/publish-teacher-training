module API
  module V2
    class ProvidersController < API::V2::ApplicationController
      before_action :get_user, if: -> { params[:user_id].present? }

      def index
        authorize Provider
        providers = policy_scope(Provider).include_courses_counts
        providers = providers.where(id: @user.providers) if @user.present?

        render jsonapi: providers.in_order, fields: { providers: %i[provider_code provider_name courses] }
      end

      def show
        provider = Provider.find_by!(provider_code: params[:code].upcase)
        authorize provider, :show?

        render jsonapi: provider, include: params[:include]
      end

    private

      def get_user
        @user = User.find(params[:user_id])
      end
    end
  end
end
