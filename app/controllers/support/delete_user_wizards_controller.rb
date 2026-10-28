# frozen_string_literal: true

module Support
  class DeleteUserWizardsController < ApplicationController
    before_action :set_wizard

    def show
      @user = @wizard.user
      render "support/users/delete"
    end

    def update
      if @wizard.save_current_step
        flash[:success] = t("support.flash.deleted", resource: "User")
        @wizard.clear_state
        redirect_to support_recruitment_cycle_users_path(params[:recruitment_cycle_year])
      else
        @user = @wizard.user
        render "support/users/delete", status: :unprocessable_entity
      end
    end

  private

    def set_wizard
      recruitment_cycle

      @wizard = DeleteUserWizard.new(
        current_step: :confirm,
        current_step_params: params,
        state_store: DeleteUserWizard::StateStores::DeleteUserWizardStore.new(repository: wizard_repository),
      )
      @wizard.recruitment_cycle_year = params[:recruitment_cycle_year]
      @wizard.user_id = params[:id]
    end

    def wizard_repository
      DeleteUserWizard::Repositories::DeleteUser.new(
        recruitment_cycle_year: params[:recruitment_cycle_year],
        user_id: params[:id],
      )
    end
  end
end
