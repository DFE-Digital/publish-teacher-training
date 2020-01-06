module Courses
  class ValidateUniqueCourseOnProviderService
    def execute(course)
      existing_courses = course.provider.courses

      existing_courses.none? do |existing_course|
        existing_course.level == course.level &&
          existing_course.is_send == course.is_send &&
          existing_course.subjects == course.subjects &&
          existing_course.age_range_in_years == course.age_range_in_years &&
          existing_course.qualification == course.qualification &&
          existing_course.program_type == course.program_type &&
          existing_course.study_mode == course.study_mode &&
          existing_course.maths == course.maths &&
          existing_course.english == course.english &&
          existing_course.science == course.science &&
          existing_course.applications_open_from == course.applications_open_from &&
          existing_course.start_date == course.start_date &&
          existing_course.sites == course.sites &&
          existing_course.accrediting_provider == course.accrediting_provider
      end
    end
  end
end
