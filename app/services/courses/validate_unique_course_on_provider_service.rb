module Courses
  class ValidateUniqueCourseOnProviderService
    def execute(new_course:)
      existing_courses = new_course.provider.courses
      new_course_attritbutes = new_course.attributes.slice(*attributes_to_compare)
      existing_courses.none? do |existing_course|
        existing_course_attributes = existing_course.attributes.slice(*attributes_to_compare)

        new_course_attritbutes == existing_course_attributes &&
          new_course.subjects == existing_course.subjects &&
          new_course.accrediting_provider == existing_course.accrediting_provider
      end
    end

  private

    def attributes_to_compare
      %w[level is_send age_range_in_years qualification program_type study_mode maths english science applications_open_from start_date]
    end
  end
end
