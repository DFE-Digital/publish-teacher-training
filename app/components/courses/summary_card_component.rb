# frozen_string_literal: true

module Courses
  class SummaryCardComponent < ViewComponent::Base
    attr_reader :course, :location, :visa_sponsorship, :short_address

    def initialize(course:, candidate: nil, location: nil, visa_sponsorship: nil, short_address: nil, provider_search: false, accredited_provider_conflicts: Set.new)
      @course = course
      @candidate = candidate
      @location = location
      @visa_sponsorship = visa_sponsorship
      @short_address = short_address
      @provider_search = provider_search
      @accredited_provider_conflicts = accredited_provider_conflicts

      super()
    end

    def title
      provider_name = content_tag(:span, course.provider_name, class: "app-search-result__provider-name")
      return provider_name if accredited_provider_name.blank? || accredited_provider_under_course?

      safe_join([
        provider_name,
        tag.span(t(".accredited_by", provider: accredited_provider_name), class: "govuk-hint govuk-!-font-size-16 app-search-result__accredited-by"),
      ])
    end

    # Only shown when the user has searched by provider, so they can see why a
    # training partner's course matched their search for its accredited provider.
    def accredited_provider_name
      return unless @provider_search
      return if course.accredited_provider_code.blank? || course.accredited_provider_code == course.provider_code

      course.accrediting_provider&.provider_name
    end

    # When a provider offers the same subject through more than one accredited
    # provider, the accredited provider sits under the course name instead.
    def accredited_provider_under_course?
      @accredited_provider_conflicts.include?([course.provider_id, course.master_subject_id])
    end

    def course_link
      url = find_course_path(
        provider_code: course.provider_code,
        course_code: course.course_code,
        location: @location,
        distance_from_location: search_by_location? ? course.minimum_distance_to_search_location.ceil : nil,
      )

      govuk_link_to(url, class: "app-search-result__course-name") do
        safe_join([
          course.name_and_code,
          tag.span(t(".course_link_provider", provider_name: course.provider_name), class: "govuk-visually-hidden"),
        ])
      end
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
      t(".location_value.from_location_html", location: sanitize(@short_address.presence || @location))
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

    def show_age_range?
      course.age_range_in_years.present?
    end

    def age_range_text
      t(".age_range", range: course.age_range_in_years.humanize)
    end

    def qualification_and_study_mode
      safe_join([
        t(".qualification_value.#{course.qualification}_html"),
        t(".study_mode.#{course.study_mode}"),
      ], ", ")
    end

    def search_by_location?
      @location.present? && course.respond_to?(:minimum_distance_to_search_location)
    end

  private

    def school_term
      t(".location_value.school_term.#{course.funding}", default: t(".location_value.school_term.default"))
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
