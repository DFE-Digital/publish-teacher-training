# frozen_string_literal: true

require "csv"

module Exports
  class AccreditedCourseList
    CSV_HEADERS = [
      "Provider",
      "Course name",
      "Course code",
      "Age range",
      "Fee or salary",
      "Qualification",
      "Full time or part time",
      "Status",
      "View on Find",
    ].freeze

    def initialize(courses:)
      @courses = courses
    end

    def data
      CSV.generate(headers: CSV_HEADERS, write_headers: true) do |csv|
        courses.find_each do |course|
          decorated_course = course.decorate

          csv << [
            decorated_course.provider.provider_name,
            decorated_course.name,
            decorated_course.course_code,
            decorated_course.age_range,
            decorated_course.funding.titleize,
            decorated_course.outcome,
            decorated_course.study_mode&.humanize,
            decorated_course.content_status&.to_s&.humanize,
            decorated_course.find_url,
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
