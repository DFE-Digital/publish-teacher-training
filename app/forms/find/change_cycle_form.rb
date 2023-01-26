# frozen_string_literal: true

module Find
  class ChangeCycleForm
    include ActiveModel::Model

    def cycle_schedule_name
      CycleTimetable.current_cycle_schedule
    end
  end
end
