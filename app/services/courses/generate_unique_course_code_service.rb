module Courses
  class GenerateUniqueCourseCodeService
    def initialize(generate_course_code_service:)
      @generate_course_code_service = generate_course_code_service
    end

    def execute(existing_codes:)
      code = nil

      while code.nil? || code.in?(existing_codes)
        code = @generate_course_code_service.execute
      end

      code
    end
  end
end
