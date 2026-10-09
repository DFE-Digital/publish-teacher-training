# frozen_string_literal: true

module Courses
  class SummaryCardComponent < ViewComponent::Base
    attr_reader :course, :location, :visa_sponsorship, :short_address

    def initialize(course:, candidate: nil, location: nil, visa_sponsorship: nil, short_address: nil)
      @course = course
      @candidate = candidate
      @location = location
      @visa_sponsorship = visa_sponsorship
      @short_address = short_address

      super()
    end

    def title
      status_tag = application_status_tag

      safe_join([
        content_tag(:span, course.provider_name, class: "app-search-result__provider-name"),
        (content_tag(:div, status_tag, class: "app-saved-course__status-tag") if status_tag.present?),
      ].compact)
    end

    def course_link
      url = find_course_path(
        provider_code: course.provider_code,
        course_code: course.course_code,
        location: @location,
        distance_from_location: search_by_location? ? course.minimum_distance_to_search_location.ceil : nil,
      )

      govuk_link_to(course.name_and_code, url, class: "app-search-result__course-name")
    end

    def save_toggle_button
      return unless candidate_accounts_enabled?

      saved_course = @candidate&.saved_courses&.find_by(course_id: course.id)
      render("find/saved_courses/save_toggle", course: course, saved_course: saved_course)
    end

    # Find result cards only show closed / after-deadline status. The grey
    # "Not yet open" cycle-phase tag is kept on Saved courses only.
    def application_status_tag
      text, colour = course.decorate.saved_status_text_and_colour
      return if text.blank? || colour == "grey"

      helpers.govuk_tag(text:, colour:)
    end

    def candidate_accounts_enabled?
      @candidate_accounts_enabled ||= FeatureFlag.active?(:candidate_accounts)
    end

    def no_employing_schools?
      course.without_employing_school?
    end

    def nearest_school_distance
      t(
        ".location_value.nearest_school_html",
        school_term:,
        distance: content_tag(:strong, pluralize(course.minimum_distance_to_search_location.ceil, "mile")),
      )
    end

    def nearest_school_from
      t(".location_value.from_location", location: sanitize(@short_address.presence || @location))
    end

    def location_hint
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

    def funding_text
      return t(".funding.#{course.funding}") if course.salary? || course.apprenticeship?

      uk_fee_line = safe_join([
        (t(".funding.fee.uk", value: number_to_currency(enrichment.fee_uk_eu.to_f)) if enrichment.fee_uk_eu.present?),
        bursary_hint,
      ].compact, " ")
      international_fee_line = t(".funding.fee.international", value: number_to_currency(enrichment.fee_international.to_f)) if enrichment.fee_international.present?

      safe_join([uk_fee_line, international_fee_line].compact_blank, tag.br)
    end

    def length_key
      t(".length_key")
    end

    def length_value(course_length = enrichment.course_length)
      translated_course_length = t(".length_value.#{course_length}", default: course_length)

      [translated_course_length, course.study_mode.humanize.downcase].join(" - ")
    end

    def show_age_range?
      course.age_range_in_years.present?
    end

    def age_range_text
      t(".age_range", range: course.age_range_in_years.humanize)
    end

    def experience_key
      t(".experience_key")
    end

    def experience_value
      t(".experience_value")
    end

    def qualification_and_study_mode
      safe_join([
        t(".qualification_value.#{course.qualification}_html"),
        t(".study_mode.#{course.study_mode}"),
      ], ", ")
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

    def search_by_location?
      @location.present? && course.respond_to?(:minimum_distance_to_search_location)
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

    def incentive_hint
      incentive_view.hint_text
    end

    def bursary_hint
      tag.span(t(".funding.bursaries_available"), class: "govuk-hint govuk-!-font-size-16") if incentive_view.has_bursary?
    end

    def incentive_view
      @incentive_view ||= CourseIncentive::View.new(CourseIncentive.new(course))
    end

    NullEnrichment = Struct.new(:course_length, :fee_uk_eu, :fee_international, keyword_init: true)

    def enrichment
      @enrichment ||= course.latest_published_enrichment || NullEnrichment.new
    end
  end
end
