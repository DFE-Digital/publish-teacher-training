# frozen_string_literal: true

module Find
  class ChangeCycleForm
    include ActiveModel::Model

    def cycle_schedule_name
      CycleTimetable.current_cycle_schedule
    end

    # The deadline banner is a window inside apply_open rather than a phase, so
    # the switcher sets it on its own axis.
    def deadline_banner
      SiteSetting.deadline_banner?
    end
  end
end
