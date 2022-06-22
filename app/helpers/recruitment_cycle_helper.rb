# frozen_string_literal: true

module RecruitmentCycleHelper
  def current_recruitment_cycle_period_text
    "#{Settings.current_recruitment_cycle_year - 1} to #{Settings.current_recruitment_cycle_year}"
  end

  def next_recruitment_cycle_period_text
    "#{Settings.current_recruitment_cycle_year} to #{Settings.current_recruitment_cycle_year + 1}"
  end

  def previous_recruitment_cycle_period_text
    "#{Settings.current_recruitment_cycle_year - 1} to #{Settings.current_recruitment_cycle_year}"
  end
end
