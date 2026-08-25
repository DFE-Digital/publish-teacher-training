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
            number_to_currency(enrichment&.fee_uk_eu),
            number_to_currency(enrichment&.fee_international),
            decorated_course.find_url,
            course.sites.map(&:code).sort.join(" "),
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
