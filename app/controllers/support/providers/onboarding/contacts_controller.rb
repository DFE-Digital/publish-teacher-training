# frozen_string_literal: true

module Support
  module Providers
    module Onboarding
      class ContactsController < SupportController
        def new
          @provider_contact_form = ProviderContactForm.new(current_user)
        end

        def create
          @provider_contact_form = ProviderContactForm.new(current_user, params: provider_form_params)

          if @provider_contact_form.stash
            redirect_to support_recruitment_cycle_providers_onboarding_check_path
          else
            render :new
          end
        end

        private

        def provider_form_params
          params.require(:support_provider_contact_form)
                .permit(ProviderContactForm::FIELDS)
        end
      end
    end
  end
end
