# frozen_string_literal: true

module Support
  module Providers
    module Onboarding
      class ChecksController < SupportController
        def show
          provider_form
          provider_contact_form
        end

        def update
          provider = recruitment_cycle.providers.new(provider_attributes)
          return unless provider.save

          reset_forms

          redirect_to support_recruitment_cycle_provider_path(recruitment_cycle.year, provider.id), flash: { success: 'Organisation added' }
        end

        private

        def reset_forms
          [provider_form, provider_contact_form].each(&:clear_stash)
        end

        def provider_form
          @provider_form = ProviderForm.new(current_user, recruitment_cycle:)
        end

        def provider_contact_form
          @provider_contact_form = ProviderContactForm.new(current_user)
        end

        def provider_attributes
          provider_form.attributes_to_save
                       .merge(provider_contact_form.attributes_to_save)
        end
      end
    end
  end
end
