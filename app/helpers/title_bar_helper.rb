# frozen_string_literal: true

module TitleBarHelper
  def render_title_bar?(current_user:, provider:)
    current_user.has_multiple_providers_in_current_recruitment_cycle? || RecruitmentCycle.upcoming_cycles_open_to_publish? || (current_user.admin? &&
    provider)
  end
end
