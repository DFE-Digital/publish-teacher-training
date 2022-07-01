module ProviderHelper
  def visa_sponsorship_status(provider)
    if !provider.declared_visa_sponsorship?
      visa_sponsorship_call_to_action(provider)
    elsif provider.can_sponsor_student_visa || provider.can_sponsor_skilled_worker_visa
      "#{visa_sponsorship_short_status(provider)} can be sponsored"
    else
      "Visas cannot be sponsored"
    end
  end

  def visa_sponsorship_short_status(provider)
    if !provider.declared_visa_sponsorship?
      visa_sponsorship_call_to_action(provider)
    elsif provider.can_sponsor_all_visas?
      "Student and Skilled Worker visas"
    elsif provider.can_only_sponsor_student_visa?
      "Student visas"
    elsif provider.can_only_sponsor_skilled_worker_visa?
      "Skilled Worker visas"
    end
  end

  def rollover_inactive
    !FeatureService.enabled?("rollover.can_edit_current_and_next_cycles")
  end

  def rollover_active_and_current_cycle?(recruitment_cycle_year)
    FeatureService.enabled?("rollover.can_edit_current_and_next_cycles") && (recruitment_cycle_year.to_i == Settings.current_recruitment_cycle_year)
  end

  def rollover_active_and_next_cycle?(recruitment_cycle_year)
    FeatureService.enabled?("rollover.can_edit_current_and_next_cycles") && (recruitment_cycle_year.to_i == Settings.current_recruitment_cycle_year + 1)
  end

private

  def visa_sponsorship_call_to_action(provider)
    govuk_inset_text(classes: "app-inset-text--narrow-border app-inset-text--important") do
      raw("<p class=\"govuk-heading-s app-inset-text__title\">Can you sponsor visas?</p>") +
        govuk_link_to(
          "Select if visas can be sponsored",
          visas_publish_provider_recruitment_cycle_path(
            provider.provider_code,
            provider.recruitment_cycle_year,
          ),
        )
    end
  end

  def google_form_url_for(settings, email, provider)
    "#{settings.url}&#{{ settings.email_entry => email, settings.provider_code_entry => provider.provider_code }.to_query}"
  end

  def is_current_cycle(cycle_year)
    Settings.current_recruitment_cycle_year == cycle_year.to_i
  end
end
