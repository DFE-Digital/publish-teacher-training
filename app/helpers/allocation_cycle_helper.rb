module AllocationCycleHelper
  def current_allocation_cycle_period_text
    "#{Settings.allocation_cycle_year} to #{Settings.allocation_cycle_year + 1}"
  end

  def next_allocation_cycle_period_text
    "#{Settings.allocation_cycle_year + 1} to #{Settings.allocation_cycle_year + 2}"
  end
end
