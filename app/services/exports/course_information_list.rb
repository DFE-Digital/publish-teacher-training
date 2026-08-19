# frozen_string_literal: true

require "csv"

module Exports
  class CourseInformationList
    include ActionView::Helpers::NumberHelper
    include CourseColumns

    CSV_HEADERS = [
      "Course name",
      "Course code",
      "Accredited provider",
      "Status",
      "Age range",
      "Fee or salary",
      "Qualification",
      "Study mode",
      "Start date",
      "Course length",
      "UK fee",
      "Non-UK fee",
    ].freeze

    def initialize(provider:)
      @provider = provider
    end

    def data
      BYTE_ORDER_MARK + CSV.generate(headers: CSV_HEADERS, write_headers: true) do |csv|
        courses.each do |course|
          enrichment = course.latest_non_draft_enrichment

          csv << [
            course.name,
            course.course_code,
            accredited_provider(course),
            status(course),
            age_range(course),
            I18n.t("publish.courses.course_table.funding.#{course.funding}"),
            course.qualifications_summary,
            course.study_mode_description.capitalize,
            start_date(course),
            course_length(enrichment&.course_length),
            number_to_currency(enrichment&.fee_uk_eu),
            number_to_currency(enrichment&.fee_international),
          ]
        end
      end
    end

    def filename
      "course-information-#{provider.provider_code}-#{Time.zone.today}.csv"
    end

  private

    attr_reader :provider

    def courses
      Publish::Courses::Query.call(provider:).preload(:latest_non_draft_enrichment)
    end

    def accredited_provider(course)
      code = course.accredited_provider_code
      return provider.provider_name if code.blank? || code == provider.provider_code

      course[:group_name] || code
    end

    def start_date(course)
      return if course.start_date.blank?

      I18n.l(course.start_date.to_date, format: :short)
    end

    def course_length(value)
      return if value.blank?

      I18n.t("courses.summary_card_component.length_value.#{value}", default: value)
    end
  end
end
