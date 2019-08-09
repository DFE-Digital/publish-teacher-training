module StartDateValid
  extend ActiveSupport::Concern
  included do
    def start_date_valid?(_recruitment_year, course)
      course_options = EditCourseOptions.new(course)
      if course_options.start_dates.include?(course.start_date.strftime('%B %Y'))
        true
      else
        course.errors.add :start_date, "#{start_date.strftime('%B %Y')} is not in the #{recruitment_cycle.year} cycle"
      end
    end
  end
end
