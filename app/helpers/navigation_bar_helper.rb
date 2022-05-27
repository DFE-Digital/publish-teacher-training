module NavigationBarHelper
  def render_navigation_bar?(provider)
    provider && !current_page?(root_path) && provider.recruitment_cycle && !request.path.include?("support")
  end
end
