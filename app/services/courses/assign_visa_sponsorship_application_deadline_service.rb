# frozen_string_literal: true

module Courses
  class AssignVisaSponsorshipApplicationDeadlineService
    def self.execute(course_params, course)
      new(course_params).execute(course)
    end

    def initialize(course_params)
      @course_params = course_params
    end

    def execute(course)
      course.visa_sponsorship_application_deadline_at = if visa_sponsorship_application_deadline_required?(course)
                                                          DateTime.new(year.to_i, month.to_i, day.to_i)
                                                                  .change(hour: 11, min: 59)
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
  end
end
