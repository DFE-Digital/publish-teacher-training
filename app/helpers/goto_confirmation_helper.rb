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

  def publish_back_link_for_adding_provider_partnership_path(param_form_key:, params:, recruitment_cycle_year:, provider:)
    return_params = params[:return_to] == "support" ? { return_to: "support" } : {}

    if goto_confirmation?(param_form_key:, params:)
      check_publish_provider_recruitment_cycle_accredited_partnerships_path(
        provider.provider_code,
        recruitment_cycle_year,
        accredited_provider_id: params[:accredited_provider_id],
        **return_params,
      )
    elsif param_form_key == :provider_partnership_form
      search_publish_provider_recruitment_cycle_accredited_providers_path(
        provider.provider_code,
        recruitment_cycle_year,
        **return_params,
      )
    elsif params[:return_to] == "support"
      support_recruitment_cycle_provider_accredited_partnerships_path(recruitment_cycle_year, provider)
    else
      publish_provider_recruitment_cycle_accredited_partnerships_path(provider.provider_code, recruitment_cycle_year)
    end
  end
end
