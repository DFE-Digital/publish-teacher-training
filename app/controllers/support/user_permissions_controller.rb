# frozen_string_literal: true

module Support
  class UserPermissionsController < ApplicationController
    def destroy
      user.remove_access_to(provider)

      redirect_to support_recruitment_cycle_user_providers_path(recruitment_cycle_year, user),
                  flash: { success: t("support.users.providers.remove.success", name: user.full_name, provider: provider.provider_name) }
    end

  private

    def recruitment_cycle_year
      params[:recruitment_cycle_year].presence || provider.recruitment_cycle_year
    end

    def user_permission
      @user_permission ||= UserPermission.find(params[:id])
    end

    def user
      @user ||= user_permission.user
    end

    def provider
      @provider ||= user_permission.provider
    end
  end
end
