# frozen_string_literal: true

module Support
  class RemoveUserProviderWizardsController < ApplicationController
    before_action :set_wizard

    def show
      assign_view_models
      render "support/users/providers/remove"
    end

    def update
      if @wizard.save_current_step
        flash[:success] = t(
          "support.users.providers.remove.success",
          name: @wizard.user.full_name,
          provider: @wizard.provider.provider_name,
        )
        @wizard.clear_state
        redirect_to support_recruitment_cycle_user_providers_path(params[:recruitment_cycle_year], @wizard.user)
      else
        assign_view_models
        render "support/users/providers/remove", status: :unprocessable_entity
      end
    end

  private

    def assign_view_models
      @user = @wizard.user
      @provider = @wizard.provider
    end

    def set_wizard
      recruitment_cycle

      @wizard = RemoveUserProviderWizard.new(
        current_step: :confirm,
        current_step_params: params,
        state_store: RemoveUserProviderWizard::StateStores::RemoveUserProviderWizardStore.new(repository: wizard_repository),
      )
      @wizard.recruitment_cycle_year = params[:recruitment_cycle_year]
      @wizard.user_id = params[:id]
      @wizard.provider_id = params[:provider_id]
    end

    def wizard_repository
      RemoveUserProviderWizard::Repositories::RemoveProvider.new(
        recruitment_cycle_year: params[:recruitment_cycle_year],
        user_id: params[:id],
        provider_id: params[:provider_id],
      )
    end
  end
end
