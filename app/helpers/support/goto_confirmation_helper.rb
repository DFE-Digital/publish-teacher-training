# frozen_string_literal: true

module Support
  module GotoConfirmationHelper
    def goto_confirmation_value(param_form_key:, params:)
      params[:goto_confirmation] || params.dig(param_form_key, :goto_confirmation)
    end

    def goto_confirmation?(param_form_key:, params:)
      goto_confirmation_value(param_form_key:, params:) == 'true'
    end

    def back_link_for_onboarding_path(param_form_key:, params:, recruitment_cycle_year:)
      if goto_confirmation?(param_form_key:, params:)
        support_recruitment_cycle_providers_onboarding_check_path(recruitment_cycle_year)
      elsif param_form_key == :support_provider_form
        support_recruitment_cycle_providers_path(recruitment_cycle_year)
      elsif param_form_key == :support_provider_contact_form
        new_support_recruitment_cycle_providers_onboarding_path(recruitment_cycle_year)
      end
    end
  end
end
