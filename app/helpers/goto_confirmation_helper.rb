# frozen_string_literal: true

module GotoConfirmationHelper
  def goto_confirmation_value(param_form_key:, params:)
    params[:goto_confirmation] || params.dig(param_form_key, :goto_confirmation)
  end

  def goto_confirmation?(param_form_key:, params:)
    goto_confirmation_value(param_form_key:, params:) == "true"
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

  # Needs ReturnToSupport in the controller (support_return_params etc.).
  def publish_back_link_for_adding_provider_partnership_path(param_form_key:, params:, recruitment_cycle_year:, provider:)
    if goto_confirmation?(param_form_key:, params:)
      check_publish_provider_recruitment_cycle_accredited_partnerships_path(
        provider.provider_code,
        recruitment_cycle_year,
        accredited_provider_id: params[:accredited_provider_id],
        **support_return_params,
      )
    elsif param_form_key == :provider_partnership_form
      search_publish_provider_recruitment_cycle_accredited_providers_path(
        provider.provider_code,
        recruitment_cycle_year,
        **support_return_params,
      )
    else
      return_path
    end
  end
end
