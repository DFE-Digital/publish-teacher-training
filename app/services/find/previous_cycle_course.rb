# frozen_string_literal: true

module Find
  # Find normally only shows the current recruitment cycle. Apply still needs a
  # stable URL for some previous-cycle courses that start after September, until
  # that start date. Enrichment format before 2026 is not compatible with the
  # current course page, so those years stay unavailable.
  class PreviousCycleCourse
    MINIMUM_CYCLE_YEAR = 2026

    def self.visible?(course)
      new(course).visible?
    end

    def initialize(course)
      @course = course
    end

    def visible?
      return false if course.blank?
      return false unless published?
      return false unless previous_cycle?
      return false unless supported_enrichment_cycle?
      return false unless starts_after_september?
      return false unless start_date_in_future?

      true
    end

  private

    attr_reader :course

    def published?
      course.is_published?
    end

    def previous_cycle?
      course.recruitment_cycle_year.to_i == CycleTimetable.previous_year
    end

    def supported_enrichment_cycle?
      course.recruitment_cycle_year.to_i >= MINIMUM_CYCLE_YEAR
    end

    def starts_after_september?
      return false if start_on.blank?

      start_on > Date.new(course.recruitment_cycle_year.to_i, 9, 30)
    end

    def start_date_in_future?
      return false if start_on.blank?

      Time.zone.today < start_on
    end

    def start_on
      course.start_date&.to_date
    end
  end
end
