# frozen_string_literal: true

module Find
  class ShowApplyOpensSoonBannerTimetable < CycleTimetable
    def self.show_apply_deadline_banner?
      false
    end

    def self.show_cycle_closed_banner?
      true
    end
  end
end
