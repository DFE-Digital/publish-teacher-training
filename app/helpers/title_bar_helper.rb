module TitleBarHelper
  def render_title_bar?(current_user:, provider:)
    (current_user.providers.where(recruitment_cycle: RecruitmentCycle.current).count > 1) || (Settings.features.can_edit_current_and_next_cycles = true) || ((current_user.admin? &&
    provider && !request.path.include?("support")) && !request.path.end_with?(provider.provider_code))
  end
end
