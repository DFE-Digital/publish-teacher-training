module TitleBarHelper
  def render_title_bar?(current_user:, provider:)
    current_user.has_multiple_providers_in_current_recruitment_cycle? || (Settings.features.can_edit_current_and_next_cycles == true) || ((current_user.admin? &&
    provider))
  end
end
