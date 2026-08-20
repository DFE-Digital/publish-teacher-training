# frozen_string_literal: true

module Courses
  class SummaryCardComponent < ViewComponent::Base
    attr_reader :course, :location, :visa_sponsorship, :short_address, :locality, :administrative_area_level_2, :postal_code

    def initialize(course:, candidate: nil, location: nil, visa_sponsorship: nil, short_address: nil, show_start_date: nil, locality: nil, administrative_area_level_2: nil, postal_code: nil, location_category: nil)
      @course = course
      @candidate = candidate
      @location = location
      @visa_sponsorship = visa_sponsorship
      @short_address = short_address
      @show_start_date = show_start_date
      @locality = locality
      @administrative_area_level_2 = administrative_area_level_2
      @postal_code = postal_code
      @location_category = location_category

      super()
    end

    def title
      find_course_path(
        provider_code: course.provider_code,
        course_code: course.course_code,
        location: @location,
        distance_from_location: search_by_location? ? course.minimum_distance_to_search_location.ceil : nil,
      )

      title_parts = [
        content_tag(
          :div,
          course.provider_name,
          class: "app-search-result__provider-name",
        ),
      ]

      title_parts << content_tag(
        :div,
        "",
        class: "govuk-body-s govuk-!-margin-bottom-0",
      )

      title_parts << content_tag(
        :div,
        search_by_location? ? nearest_placement_school_text : "",
        class: "govuk-body-s govuk-!-margin-bottom-0",
      )

      title_content = safe_join(title_parts)

      classes = [
        ("govuk-grid-column-one-half" if save_toggle_button),
        ("govuk-!-padding-left-2" unless save_toggle_button),
      ].compact.join(" ")

      content_tag(:div, class: "govuk-grid-row") do
        safe_join([
          content_tag(:div, title_content, class: classes),
          content_tag(
            :div,
            save_toggle_button || "",
            class: "govuk-grid-column-one-half govuk-!-padding-top-2 govuk-!-padding-right-0",
          ),
        ])
      end
    end

    def nearest_placement_school_text
      return unless search_by_location?

      from_text = centre_location? ? " from the centre of " : " from "

      safe_join([
        content_tag(
          :strong,
          pluralize(course.minimum_distance_to_search_location.ceil, "mile"),
        ),
        from_text,
        content_tag(
          :strong,
          @short_address.presence || @location,
        ),
      ])
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

    def centre_location?
      postal_code.blank? &&
        (
          locality.present? ||
          administrative_area_level_2.present?
        )
    end

    def location_value
      return unless search_by_location?

      translation_key =
        if centre_location?
          ".location_value.distance_from_centre"
        else
          ".location_value.distance"
        end

      t(
        translation_key,
        school_term:,
        distance: content_tag(
          :span,
          pluralize(course.minimum_distance_to_search_location.ceil, "mile"),
          class: "govuk-!-font-weight-bold",
        ),
        location: content_tag(
          :span,
          sanitize(@short_address.presence || @location),
          class: "govuk-!-font-weight-bold",
        ),
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

    def experience_key
      t(".experience_key")
    end

    def experience_value
      t(".experience_value")
    end

    def qualification_value
      t(".qualification_value.#{course.qualification}_html")
    end

    def study_mode_value
      t(".study_mode_value.#{course.study_mode}")
    end

    def funding_value
      t(".funding_value.#{course.funding}")
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

    def show_start_date?
      @show_start_date.presence
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

    def incentive_view
      @incentive_view ||= CourseIncentive::View.new(CourseIncentive.new(course))
    end

    NullEnrichment = Struct.new(:course_length, :fee_uk_eu, :fee_international, keyword_init: true)

    def enrichment
      @enrichment ||= course.latest_published_enrichment || NullEnrichment.new
    end
  end
end
