module Providers
  class GenerateUniqueCourseCodeService
    def initialize(generate_course_code_service:)
      @generate_course_code_service = generate_course_code_service
    end

    def execute(existing_codes:)
      code = nil

      code = @generate_course_code_service.execute while code.nil? || code.in?(existing_codes)

      code
    end
  end
end
