module NavigationBarHelper
  def render_navigation_bar?(provider)
    !request.path.include?("support") &&
    provider && !current_page?(root_path) && !current_page?(publish_provider_path(provider.provider_code)) &&
    provider.recruitment_cycle
  end
end
