module RecruitmentCycleHelper
  def current_recruitment_cycle_period_text
    "#{Settings.current_cycle} to #{Settings.current_cycle + 1}"
  end

  def next_recruitment_cycle_period_text
    "#{Settings.current_cycle + 1} to #{Settings.current_cycle + 2}"
  end

  def previous_recruitment_cycle_period_text
    "#{Settings.current_cycle - 1} to #{Settings.current_cycle}"
  end
end
