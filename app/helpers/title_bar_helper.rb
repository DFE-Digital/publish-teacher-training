module TitleBarHelper
  def render_title_bar?(current_user:, provider:)
    current_user.has_multiple_providers_in_current_recruitment_cycle? || ((current_user.admin? &&
    provider && !request.path.include?("support")) && !request.path.end_with?(provider.provider_code))
  end
end
