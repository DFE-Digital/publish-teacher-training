module Publish
  module DataExports
    class CourseInformationExport < Support::DataExports::Base
      def initialize(courses:, provider:, params: {}) # rubocop:disable Lint/MissingSuper
        @courses = courses
        @provider = provider
        @params = params
      end

      def data
        @courses.map do |course|
          {
            "Course code" => course.course_code,
            "Course name" => course.name.titleize,
            "Status" => status(course).titleize,
            "Funding" => course.funding.titleize,
            "Qualification" => qualification(course),
            "Study mode" => course.study_mode.titleize,
            "Start date" => format_date(course.start_date),
            "Placement schools" => placement_schools(course),
          }
        end
      end

    private

      def placement_schools(course)
        course.site_statuses
              .filter_map { |status| status.site&.location_name }
              .join(", ")
      end

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
