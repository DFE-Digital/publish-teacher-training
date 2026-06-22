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
              "Status" => status(course).titleize,
              "Funding" => course.funding.titleize,
              "Qualification" => qualification(course),
              "Study mode" => course.study_mode.titleize,
              "Start date" => format_date(course.start_date),
              "Placement school" => site.location_name || site.code,
            }
          end
        end

        rows
      end

    private

      def format_date(date)
        date&.strftime("%B %Y")
      end

      def qualification(course)
        case course.qualification
        when "qts_with_pgce" then "PGCE with QTS"
        when "qts_only" then "QTS"
        else course.qualification.humanize
        end
      end

      def status(course)
        if course.is_withdrawn?
          "Withdrawn"
        elsif course.scheduled?
          "Scheduled"
        elsif course.content_status == :draft
          "Draft"
        elsif course.content_status == :rolled_over
          "Rolled over"
        elsif course.open_for_applications?
          "Open"
        elsif course.only_published? && !course.open_for_applications?
          "Closed"
        else
          "Unknown"
        end
      end
    end
  end
end
