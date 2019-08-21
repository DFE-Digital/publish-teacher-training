module Courses
  class GenerateUniqueCourseCodeService
    def initialize(existing_codes:, generate_course_code_service:)
      @existing_codes = existing_codes
      @generate_course_code_service = generate_course_code_service
    end

    def execute
      code = nil

      while code.nil? || code.in?(@existing_codes)
        code = @generate_course_code_service.execute
      end

      code
    end
  end
end
