# frozen_string_literal: true

module Courses
  class AssignVisaSponsorshipApplicationDeadlineService
    def self.execute(course_params, course)
      new(course_params).execute(course)
    end

    def initialize(course_params)
      @course_params = course_params
    end

    # We use DateTime here instead of Time.zone because DateTime is better at
    # validating dates.
    # Time.zone.local(2026, 2, 31) # => => 2026-03-03 00:00:00.000000000 GMT +00:00
    # DateTime.new(2026, 2, 31) # => Date::Error: invalid date (Date::Error)
    def execute(course)
      return unless deadline_date_params_are_sent

      course.visa_sponsorship_application_deadline_at = if visa_sponsorship_application_deadline_required?(course)
                                                          DateTime.new(year.to_i, month.to_i, day.to_i) # rubocop:disable Style/DateTime
                                                                  .in_time_zone
                                                                  .end_of_day
                                                        end
    rescue Date::Error
      course.visa_sponsorship_application_deadline_at = Struct.new(:year, :month, :day).new(year, month, day)
    end

  private

    def visa_sponsorship_application_deadline_required?(course)
      course.visa_sponsorship != :no_sponsorship &&
        ActiveModel::Type::Boolean.new.cast(@course_params["visa_sponsorship_application_deadline_required"])
    end

    def year
      @course_params["visa_sponsorship_application_deadline_at(1i)"]
    end

    def month
      @course_params["visa_sponsorship_application_deadline_at(2i)"]
    end

    def day
      @course_params["visa_sponsorship_application_deadline_at(3i)"]
    end

    def deadline_date_params_are_sent
      @course_params.key?("visa_sponsorship_application_deadline_at(1i)")
    end
  end
end
