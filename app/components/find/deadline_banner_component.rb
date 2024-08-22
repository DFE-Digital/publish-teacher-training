# frozen_string_literal: true

module Find
  class DeadlineBannerComponent < ViewComponent::Base
    attr_accessor :flash_empty

    def initialize(flash_empty:, cycle_timetable: Find::CycleTimetable)
      super
      @flash_empty = flash_empty
      @cycle_timetable = cycle_timetable
    end

    def render?
      flash_empty && !cycle_timetable.find_down?
    end

    private

    attr_reader :cycle_timetable

    def apply_deadline
      cycle_timetable.apply_deadline.to_fs(:govuk_date_and_time)
    end

    def cycle_year_range
      cycle_timetable.cycle_year_range
    end

    def find_opens
      cycle_timetable.find_opens.to_fs(:month_and_year)
    end

    def find_reopens
      cycle_timetable.find_reopens.to_fs(:govuk_date_and_time)
    end

    def apply_reopens
      cycle_timetable.apply_reopens.to_fs(:govuk_date_and_time)
    end

    def apply_opens
      cycle_timetable.apply_opens.to_fs(:day_and_month)
    end

    def previous_cycle_year_range
      cycle_timetable.cycle_year_range(cycle_timetable.previous_year)
    end
  end
end
