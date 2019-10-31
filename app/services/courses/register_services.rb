module Courses
  class RegisterServices
    def self.execute(container)
      container.define(:courses, :generate_course_code) do
        Courses::GenerateCourseCodeService.new
      end

      container.define(:courses, :generate_course_title) do
        Courses::GenerateCourseTitleService.new
      end

      container.define(:courses, :generate_unique_course_code) do
        Courses::GenerateUniqueCourseCodeService.new(
          generate_course_code_service: container.get(:courses, :generate_course_code),
        )
      end

      container.define(:courses, :copy_to_provider) do
        Courses::CopyToProviderService.new(
          sites_copy_to_course: container.get(:sites, :copy_to_course),
          enrichments_copy_to_course: container.get(:enrichments, :copy_to_course),
        )
      end
    end
  end
end
