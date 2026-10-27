# frozen_string_literal: true

module Support
  module Users
    class ProvidersController < ApplicationController
      def show
        user
        @pagy, @providers = pagy(providers.order(:provider_name))
      end

      def remove
        user
        provider
        @user_permission = user.user_permissions.find_by!(provider_id: provider.id)
      end

    private

      # The providers list is /users/:user_id/providers. The confirmation page is a
      # member route, /users/:id/providers/:provider_id/remove. Both actions use
      # this lookup, so it reads whichever parameter the route set.
      def user
        @user ||= User.find(params[:user_id] || params[:id])
      end

      def provider
        @provider ||= user.providers.find(params[:provider_id])
      end

      def providers
        recruitment_cycle.providers.where(id: user.providers)
      end
    end
  end
end
