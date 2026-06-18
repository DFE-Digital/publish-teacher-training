module Publish
  module DataExports
    class CourseSchoolsExport < Support::DataExports::Base
      def initialize(courses:) # rubocop:disable Lint/MissingSuper
        @courses = courses
      end

      def data
        rows = []

        @courses.each do |course|
          course.site_statuses.each do |status|
            site = status.site
            next unless site

            rows << {
              "Course name" => course.name.titleize,
              "Course code" => course.course_code,
              "Placement school" => site.location_name || site.code,
            }
          end
        end

        rows
      end
    end
  end
end
