# frozen_string_literal: true

module Support
  class AddUserWizardsController < ApplicationController
    CACHE_EXPIRY = 24.hours

    before_action :set_wizard, except: :new

    helper_method :current_step, :current_step_name

    def new
      redirect_to wizard_support_recruitment_cycle_users_path(
        params[:recruitment_cycle_year],
        state_key: SecureRandom.uuid,
        step: :details,
      )
    end

    def show; end

    def update
      if @wizard.save_current_step
        return complete if @wizard.final_step?

        redirect_to @wizard.next_step_path
      else
        render :show, status: :unprocessable_content
      end
    end

    def current_step
      @wizard.current_step
    end

    def current_step_name
      params[:step].to_sym
    end

  private

    def complete
      flash[:success] = t("support.users.checks.update.success")
      @wizard.clear_state
      redirect_to support_recruitment_cycle_users_path(params[:recruitment_cycle_year])
    end

    def set_wizard
      recruitment_cycle

      @wizard = AddUserWizard.new(
        current_step: current_step_name,
        current_step_params: params,
        state_store: AddUserWizard::StateStores::AddUserWizardStore.new(repository: wizard_repository),
      )
      @wizard.recruitment_cycle_year = params[:recruitment_cycle_year]
      @wizard.state_key = params[:state_key]
    end

    def wizard_repository
      AddUserWizard::Repositories::AddUser.new(
        recruitment_cycle_year: params[:recruitment_cycle_year],
        state_key: params[:state_key],
        expires_in: CACHE_EXPIRY,
      )
    end
  end
end
