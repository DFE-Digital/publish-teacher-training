module NavigationBarHelper
  def render_navigation_bar?(provider)
    provider && !current_page?(root_path) && !current_page?(publish_provider_path(provider.provider_code)) &&
    provider.recruitment_cycle &&
    !request.path.include?("support")
  end
end
