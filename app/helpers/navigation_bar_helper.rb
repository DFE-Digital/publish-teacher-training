# frozen_string_literal: true

module NavigationBarHelper
  def render_navigation_bar?(provider)
    request.path.exclude?('support') &&
      provider && !current_page?(root_path) && !current_page?(publish_provider_path(provider.provider_code)) &&
      provider.recruitment_cycle
  end

  def navigation_items(provider)
    [
      { name: t('navigation_bar.courses'), url: publish_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year) },
      { name: t('navigation_bar.schools'), url: publish_provider_recruitment_cycle_schools_path(provider.provider_code, provider.recruitment_cycle_year) },
      *([name: t('navigation_bar.study_sites'), url: publish_provider_recruitment_cycle_study_sites_path(provider.provider_code, provider.recruitment_cycle_year)] if recruitment_cycle_after_2023?(provider)),
      { name: t('navigation_bar.users'), url: publish_provider_users_path(provider_code: provider.provider_code), additional_url: request_access_publish_provider_path(provider.provider_code) },
      *([name: t('navigation_bar.training_partners'), url: publish_provider_recruitment_cycle_training_providers_path(provider.provider_code, provider.recruitment_cycle_year)] if provider.accredited_provider?),
      *([name: t('navigation_bar.accredited_provider'), url: publish_provider_recruitment_cycle_accredited_providers_path(provider.provider_code, provider.recruitment_cycle_year)] unless provider.accredited_provider?),
      { name: t('navigation_bar.organisation_details'), url: details_publish_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle_year) }
    ]
  end
end
