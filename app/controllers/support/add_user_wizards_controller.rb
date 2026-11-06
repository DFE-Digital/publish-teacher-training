# frozen_string_literal: true

module Support
  class AddUserWizardsController < ApplicationController
    include BaseWizardController

    before_action :recruitment_cycle

  private

    def wizard_class = AddUserWizard

    def wizard_context = { recruitment_cycle_year: params[:recruitment_cycle_year] }

    def wizard_success_message = t("support.users.checks.update.success")
  end
end
