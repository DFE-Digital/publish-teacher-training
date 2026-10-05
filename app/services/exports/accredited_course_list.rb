# frozen_string_literal: true

require "csv"

module Exports
  class AccreditedCourseList
    include ActionView::Helpers::NumberHelper
    include CourseColumns

    CSV_HEADERS = [
      "Provider",
      "Provider code",
      "Course name",
      "Course code",
      "Status",
      "Age range",
      "Fee or salary",
      "Qualification",
      "Full time or part time",
      "Start date",
      "Course length",
      "UK fee",
      "Non-UK fee",
      "View on Find",
      "Campus codes",
    ].freeze

    def initialize(courses:)
      @courses = courses
    end

    def data
      BYTE_ORDER_MARK + CSV.generate(headers: CSV_HEADERS, write_headers: true) do |csv|
        courses.find_each do |course|
          decorated_course = course.decorate
          enrichment = reported_enrichment(course)

          csv << [
            course.provider.provider_name,
            course.provider.provider_code,
            course.name,
            course.course_code,
            course.content_status&.to_s&.humanize,
            age_range(course),
            I18n.t("publish.courses.course_table.funding.#{course.funding}"),
            decorated_course.outcome,
            course.study_mode_description.capitalize,
            start_date(course),
            course_length(enrichment&.course_length),
            fee(course, enrichment&.fee_uk_eu),
            fee(course, enrichment&.fee_international),
            decorated_course.find_url,
            campus_codes(course),
          ]
        end
      end
    end

    def filename
      "courses-#{Time.zone.today}.csv"
    end

  private

    attr_reader :courses

    def campus_codes(course)
      course.schools
        .map(&:site_code)
        .sort_by { |site_code| [campus_code_sort_order(site_code), site_code] }
        .join(" ")
    end

    def campus_code_sort_order(site_code)
      return 2 if site_code == Provider::School::MAIN_SITE_CODE
      return 1 if site_code.match?(/\A\d/)

      0
    end
  end
end
