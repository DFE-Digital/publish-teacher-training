# frozen_string_literal: true

module Support
  module Providers
    module Onboarding
      class ContactsController < SupportController
        include GotoConfirmationHelper

        def new
          recruitment_cycle
          @support_provider_contact_form = ProviderContactForm.new(current_user)
        end

        def create
          recruitment_cycle
          @support_provider_contact_form = ProviderContactForm.new(current_user, params: provider_form_params)

          if @support_provider_contact_form.stash
            redirect_to support_recruitment_cycle_providers_onboarding_check_path
          else
            render :new
          end
        end

        private

        def param_form_key = :support_provider_contact_form

        def provider_form_params
          params.require(param_form_key)
                .except(:goto_confirmation)
                .permit(ProviderContactForm::FIELDS)
        end
      end
    end
  end
end
