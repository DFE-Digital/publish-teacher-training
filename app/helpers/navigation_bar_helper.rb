module NavigationBarHelper
  def render_navigation_bar?(provider)
    !request.path.include?("support") &&
    provider && !current_page?(root_path) && !current_page?(publish_provider_path(provider.provider_code)) &&
    provider.recruitment_cycle
  end

  def navigation_items(provider)
    [
      { name: t("navigation_bar.courses"), url: publish_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year) },
      { name: t("navigation_bar.locations"), url: publish_provider_recruitment_cycle_locations_path(provider.provider_code, provider.recruitment_cycle_year) },
      { name: t("navigation_bar.users"), url: users_publish_provider_path(code: provider.provider_code), additional_url: request_access_publish_provider_path(provider.provider_code) },
      *([name: t("navigation_bar.training_partners"), url: publish_provider_recruitment_cycle_training_providers_path(provider.provider_code, provider.recruitment_cycle_year)] if provider.accredited_body?),
      { name: t("navigation_bar.organisation_details"), url: details_publish_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle_year) },
    ]
  end
end
