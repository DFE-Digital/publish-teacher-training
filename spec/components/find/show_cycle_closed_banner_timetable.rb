# frozen_string_literal: true

module Find
  class ShowCycleClosedBannerTimetable < CycleTimetable
    def self.show_apply_deadline_banner?
      false
    end

    def self.show_cycle_closed_banner?
      false
    end

    def self.show_apply_opens_soon_banner?
      true
    end
  end
end
