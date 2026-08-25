# frozen_string_literal: true

module Exports
  module CourseColumns
    # A CSV carries no encoding declaration, so Excel falls back to the legacy
    # Windows code page and renders the UTF-8 "£" (C2 A3) as "Â£". This byte
    # order mark, written first, tells it the file is UTF-8.
    BYTE_ORDER_MARK = "\uFEFF"

    def status(course)
      Publish::Courses::StatusTag.token(course).to_s.humanize
    end

    def age_range(course)
      return if course.age_range_in_years.blank?

      course.decorate.age_range
    end

    # Use status as CourseEnrichment#draft? also counts rolled_over
    def reported_enrichment(course)
      settled = course.enrichments.reject { |enrichment| enrichment.status == "draft" }
      settled.max_by { |enrichment| [enrichment.created_at, enrichment.id] } || course.latest_enrichment
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
