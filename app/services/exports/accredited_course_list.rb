# frozen_string_literal: true

require "csv"

module Exports
  class AccreditedCourseList
    CSV_HEADERS = [
      "Provider code",
      "Provider",
      "Course code",
      "Course",
      "Study mode",
      "Programme type",
      "Qualification",
      "Status",
      "View on Find",
      "Applications open from",
      "Campus Codes",
    ].freeze

    def initialize(courses:)
      @courses = courses
    end

    def data
      CSV.generate(headers: CSV_HEADERS, write_headers: true) do |csv|
        courses.find_each do |course|
          decorated_course = course.decorate

          csv << [
            decorated_course.provider.provider_code,
            decorated_course.provider.provider_name,
            decorated_course.course_code,
            decorated_course.name,
            decorated_course.study_mode&.humanize,
            decorated_course.program_type&.humanize,
            decorated_course.outcome,
            decorated_course.content_status&.to_s&.humanize,
            decorated_course.find_url,
            I18n.l(decorated_course.applications_open_from&.to_date),
            decorated_course.sites&.map(&:code)&.join(" "),
          ]
        end
      end
    end

    def filename
      "courses-#{Time.zone.today}.csv"
    end

  private

    attr_reader :courses
  end
end
