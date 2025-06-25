# frozen_string_literal: true

module Courses
  class SummaryCardComponent < ViewComponent::Base
    attr_reader :course, :location, :visa_sponsorship

    def initialize(course:, location: nil, postcode: nil, visa_sponsorship: nil)
      @course = course
      @location = location
      @visa_sponsorship = visa_sponsorship
      @postcode = postcode
      super
    end

    def title
      govuk_link_to(find_course_path(
                      provider_code: course.provider_code,
                      course_code: course.course_code,
                      location: @location,
                      distance_from_location: search_by_location? ? course.minimum_distance_to_search_location.ceil : nil,
                    ), class: "govuk-link govuk-!-font-size-24") do
        safe_join(
          [
            content_tag(:span, course.provider_name, class: "app-search-result__provider-name"),
            content_tag(:span, course.name_and_code, class: "app-search-result__course-name"),
          ],
        )
      end
    end

    def location_value
      return unless search_by_location?

      # Searching by city or region, we need to add the first part of the postcode in this format: e.g. York YO1, UK
      # If location name ends with ", UK" then insert the first part of the postcode before this
      if @location.end_with?(", UK") && postcode_area.present?
        location_without_country = @location.sub(", UK", "")
        country = @location.split(", ").last

        formatted_location = if location_without_country.include?(postcode_area)
                               "#{location_without_country}, #{country}"
                             else
                               "#{location_without_country} #{postcode_area}, #{country}"
                             end
      else
        formatted_location = @location
      end

      t(
        ".location_value.distance",
        school_term:,
        distance: content_tag(:span, pluralize(course.minimum_distance_to_search_location.ceil, "mile"), class: "govuk-!-font-weight-bold"),
        location: content_tag(:span, sanitize(formatted_location), class: "govuk-!-font-weight-bold"),
      ).html_safe
    end

    def postcode_area
      return if @postcode.blank?

      @postcode.split(" ").first
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

    def fee_hint
      return if course.salary? || course.apprenticeship? || hide_fee_hint?

      if financial_incentive.bursary_amount.present? && financial_incentive.scholarship.present?
        t(
          ".fee_value.fee.hint.bursaries_and_scholarship_html",
          bursary_amount: number_to_currency(financial_incentive.bursary_amount),
          scholarship_amount: number_to_currency(financial_incentive.scholarship),
        )
      elsif financial_incentive.bursary_amount.present?
        t(
          ".fee_value.fee.hint.bursaries_only_html",
          bursary_amount: number_to_currency(financial_incentive.bursary_amount),
        )
      elsif financial_incentive.scholarship.present?
        t(
          ".fee_value.fee.hint.scholarship_only_html",
          scholarship_amount: number_to_currency(financial_incentive.scholarship),
        )
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

    def hide_fee_hint?
      !bursary_and_scholarship_flag_active_or_preview? ||
        (search_by_visa_sponsorship? && !physics? && !languages?) ||
        financial_incentive.blank?
    end

    def search_by_visa_sponsorship?
      @visa_sponsorship.present?
    end

    PHYSICS_SUBJECT = "Physics"
    private_constant :PHYSICS_SUBJECT

    def physics?
      main_subject&.subject_name == PHYSICS_SUBJECT
    end

    LANGUAGE_SUBJECTS = [
      "Ancient Greek",
      "Ancient Hebrew",
      "English",
      "English as a second or other language",
      "French",
      "German",
      "Italian",
      "Japanese",
      "Latin",
      "Mandarin",
      "Modern Languages",
      "Modern languages (other)",
      "Russian",
      "Spanish",
    ].freeze
    private_constant :LANGUAGE_SUBJECTS

    def languages?
      main_subject&.subject_name.in?(LANGUAGE_SUBJECTS)
    end

    def financial_incentive
      @financial_incentive ||= main_subject&.financial_incentive
    end

    def main_subject
      @main_subject ||= course.subjects.find { |subject| subject.id == course.master_subject_id }
    end

    NullEnrichment = Struct.new(:course_length, :fee_uk_eu, :fee_international, keyword_init: true)
    # rubocop:enable Lint/UselessConstantScoping

    def enrichment
      @enrichment ||= course.latest_published_enrichment || NullEnrichment.new
    end

    def bursary_and_scholarship_flag_active_or_preview?
      FeatureFlag.active?(:bursaries_and_scholarships_announced)
    end
  end
end
