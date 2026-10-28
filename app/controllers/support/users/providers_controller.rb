# frozen_string_literal: true

module Support
  module Users
    class ProvidersController < ApplicationController
      def show
        user
        @pagy, @providers = pagy(providers.order(:provider_name))
      end

      def remove
        recruitment_cycle
        user
        provider
      end

      def destroy
        UserAssociationsService::Delete.call(user:, providers: provider)

        redirect_to support_recruitment_cycle_user_providers_path(params[:recruitment_cycle_year], user),
                    flash: { success: t("support.users.providers.remove.success", name: user.full_name, provider: provider.provider_name) }
      end

    private

      # The providers list is /users/:user_id/providers. The confirmation page is
      # /users/:id/providers/:provider_id/remove. Both actions use this lookup.
      def user
        @user ||= User.find(params[:user_id] || params[:id])
      end

      def provider
        @provider ||= providers.find(params[:provider_id])
      end

      def providers
        recruitment_cycle.providers.where(id: user.providers)
      end
    end
  end
end
