module TitleBarHelper
  def render_title_bar?(current_user:, provider:)
    current_user.has_multiple_providers_in_current_recruitment_cycle? || FeatureService.enabled?("rollover.can_edit_current_and_next_cycles") || ((current_user.admin? &&
    provider))
  end
end
