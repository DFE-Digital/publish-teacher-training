# frozen_string_literal: true

module Find
  class DeadlineBannerComponentPreview < ViewComponent::Preview
    def show_apply_deadline_banner
      render(
        Find::DeadlineBannerComponent.new(
          flash_empty: true,
          cycle_timetable: ShowApplyDeadlineBannerCycleTimetable
        )
      )
    end

    def show_cycle_closed_banner
      render(
        Find::DeadlineBannerComponent.new(
          flash_empty: true,
          cycle_timetable: ShowCycleClosedBannerTimetable
        )
      )
    end

    def show_apply_opens_soon_banner
      render(
        Find::DeadlineBannerComponent.new(
          flash_empty: true,
          cycle_timetable: ShowApplyOpensSoonBannerTimetable
        )
      )
    end
  end

  class ShowApplyDeadlineBannerCycleTimetable < CycleTimetable
    def self.show_apply_deadline_banner?
      true
    end

    def self.show_cycle_closed_banner?
      false
    end
  end

  class ShowCycleClosedBannerTimetable < CycleTimetable
    def self.show_apply_deadline_banner?
      false
    end

    def self.show_cycle_closed_banner?
      true
    end
  end

  class ShowApplyOpensSoonBannerTimetable < CycleTimetable
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
