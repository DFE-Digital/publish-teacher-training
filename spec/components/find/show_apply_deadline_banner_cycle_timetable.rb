# frozen_string_literal: true

module Find
  class ShowApplyDeadlineBannerCycleTimetable < CycleTimetable
    def self.show_apply_deadline_banner?
      true
    end

    def self.show_cycle_closed_banner?
      false
    end
  end
end
