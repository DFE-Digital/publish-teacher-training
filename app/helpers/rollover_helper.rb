module RolloverHelper
  def rollover_inactive
    !rollover_active
  end

  def rollover_active?
    FeatureService.enabled?("rollover.can_edit_current_and_next_cycles")
  end

  def rollover_active_and_current_cycle?(recruitment_cycle_year)
    FeatureService.enabled?("rollover.can_edit_current_and_next_cycles") && (recruitment_cycle_year.to_i == Settings.current_recruitment_cycle_year)
  end

  def rollover_active_and_next_cycle?(recruitment_cycle_year)
    FeatureService.enabled?("rollover.can_edit_current_and_next_cycles") && (recruitment_cycle_year.to_i == Settings.current_recruitment_cycle_year + 1)
  end
end
