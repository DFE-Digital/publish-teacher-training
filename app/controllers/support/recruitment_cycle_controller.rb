module Support
  class RecruitmentCycleController < SupportController
    def index
      unless FeatureService.enabled?("rollover.can_edit_current_and_next_cycles")
        redirect_to support_recruitment_cycle_providers_path(Settings.current_recruitment_cycle_year)
      end
    end
  end
end
