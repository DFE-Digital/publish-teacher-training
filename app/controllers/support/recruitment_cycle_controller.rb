# frozen_string_literal: true

module Support
  class RecruitmentCycleController < SupportController
    def index
      redirect_to support_recruitment_cycle_providers_path(Settings.current_recruitment_cycle_year) unless FeatureService.enabled?('rollover.can_edit_current_and_next_cycles')
    end
  end
end
