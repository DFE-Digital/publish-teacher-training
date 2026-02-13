# frozen_string_literal: true

module Courses
  class SummaryCardComponent < ViewComponent::Base
    attr_reader :course, :location, :visa_sponsorship, :short_address

    def initialize(course:, candidate: nil, location: nil, visa_sponsorship: nil, short_address: nil, show_start_date: nil)
      @course = course
      @candidate = candidate
      @location = location
      @visa_sponsorship = visa_sponsorship
      @short_address = short_address
      @show_start_date = show_start_date

      super
    end

    def title
      course_link = govuk_link_to(find_course_path(
                                    provider_code: course.provider_code,
                                    course_code: course.course_code,
                                    location: @location,
                                    distance_from_location: search_by_location? ? course.minimum_distance_to_search_location.ceil : nil,
                                  ), class: "govuk-link govuk-!-font-size-24") do
        safe_join([
          content_tag(:span, course.provider_name, class: "app-search-result__provider-name"),
          content_tag(:span, course.name_and_code, class: "app-search-result__course-name"),
        ])
      end

      classes = [
        ("govuk-grid-column-one-half" if save_toggle_button),
        ("govuk-!-padding-left-2" unless save_toggle_button),
      ].compact.join(" ")

      content_tag(:div, class: "govuk-grid-row") do
        safe_join([
          content_tag(:div, course_link, class: classes),
          content_tag(:div, save_toggle_button || "", class: "govuk-grid-column-one-half govuk-!-padding-top-2 govuk-!-padding-right-0"),
        ])
      end
    end

    def save_toggle_button
      return unless candidate_accounts_enabled?

      saved_course = @candidate&.saved_courses&.find_by(course_id: course.id)
      render("find/saved_courses/save_toggle", course: course, saved_course: saved_course)
    end

    def candidate_accounts_enabled?
      @candidate_accounts_enabled ||= FeatureFlag.active?(:candidate_accounts)
    end

    def location_value
      return unless search_by_location?

      t(
        ".location_value.distance",
        school_term:,
        distance: content_tag(:span, pluralize(course.minimum_distance_to_search_location.ceil, "mile"), class: "govuk-!-font-weight-bold"),
        location: content_tag(:span, sanitize(@short_address.presence || @location), class: "govuk-!-font-weight-bold"),
      ).html_safe
    end

    def location_hint
      return if search_by_location?

      t(".location_value.placement_hint_html", school_term:)
    end

    def fee_key
      t(".fee_key")
    end

    def fee_value
      if course.salary? || course.apprenticeship?
        t(".fee_value.#{course.funding}")
      else
        safe_join([uk_fees, international_fees].compact_blank, tag.br)
      end
    end

    def length_key
      t(".length_key")
    end

    def length_value(course_length = enrichment.course_length)
      translated_course_length = t(".length_value.#{course_length}", default: course_length)

      [translated_course_length, course.study_mode.humanize.downcase].join(" - ")
    end

    def show_age_group_row?
      course.age_range_in_years.present?
    end

    def age_group_key
      t(".age_group_key")
    end

    def age_group_value
      "#{course.level.humanize} - #{course.age_range_in_years.humanize}"
    end

    def qualification_key
      t(".qualification_key")
    end

    def qualification_value
      t(".qualification_value.#{course.qualification}_html")
    end

    def degree_requirements_key
      t(".degree_requirements_key")
    end

    def degree_requirements_value
      t(".degree_requirements_value.#{course.degree_type}.#{course.degree_grade}")
    end

    def degree_requirements_hint
      return if course.undergraduate_degree_type?

      t(".degree_requirements_hint.#{course.degree_grade}.html")
    end

    def visa_sponsorship_key
      t(".visa_sponsorship_key")
    end

    def visa_sponsorship_value
      t(".visa_sponsorship_value.#{course.visa_sponsorship}")
    end

    def financial_incentives
      CourseFinancialSupport.new(course).hint_text(visa_sponsorship: @visa_sponsorship)
    end

    def search_by_location?
      @location.present? && course.respond_to?(:minimum_distance_to_search_location)
    end

    def show_start_date?
      FeatureFlag.active?(:find_filtering_and_sorting) && @show_start_date
    end

  private

    def school_term
      t(".location_value.school_term.#{course.funding}", default: t(".location_value.school_term.default"))
    end

    def uk_fees(fee_uk = enrichment.fee_uk_eu)
      t(".fee_value.fee.uk_fees_html", value: content_tag(:b, number_to_currency(fee_uk.to_f))) if fee_uk.present?
    end

    def international_fees(fee_international = enrichment.fee_international)
      t(".fee_value.fee.international_fees_html", value: content_tag(:b, number_to_currency(fee_international.to_f))) if fee_international.present?
    end

    NullEnrichment = Struct.new(:course_length, :fee_uk_eu, :fee_international, keyword_init: true)

    def enrichment
      @enrichment ||= course.latest_published_enrichment || NullEnrichment.new
    end
  end
end
