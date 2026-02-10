# frozen_string_literal: true

module SavedCourses
  class SummaryCardComponent < ViewComponent::Base
    include FinancialIncentiveHintHelper

    attr_reader :saved_course

    def initialize(saved_course:)
      @saved_course = saved_course
      super
    end

    def course
      @course ||= saved_course.course
    end

    def title
      provider_span = content_tag(:span, course.provider_name)
      course_span = content_tag(:span, course.name_and_code)
      status_tag = course.decorate.saved_status_tag
      status_block = (content_tag(:div, status_tag, class: "app-saved-course__status-tag") if status_tag.present?)

      title_inner = safe_join(
        [
          provider_span,
          tag.br,
          course_span,
          status_block,
        ].compact,
      )

      course_info =
        if course.is_withdrawn?
          content_tag(:div, title_inner)
        else
          govuk_link_to(
            find_course_path(provider_code: course.provider_code, course_code: course.course_code),
            class: "govuk-link",
          ) { title_inner }
        end

      content_tag(:div, class: "app-saved-course__card-title") do
        safe_join(
          [
            content_tag(:div, course_info),
            content_tag(:div, delete_action, class: "app-saved-course__card-title-delete"),
          ],
        )
      end
    end

    def delete_action
      button_to(
        t(".delete"),
        find_candidate_saved_course_path(saved_course),
        method: :delete,
        class: "app-button-link",
      )
    end

    def fee_or_salary_value
      if course.salary? || course.apprenticeship?
        t(".fee_value.#{course.funding}")
      else
        safe_join([uk_fees, international_fees].compact_blank, tag.br)
      end
    end

  private

    def uk_fees
      fee_uk = enrichment.fee_uk_eu
      return if fee_uk.blank?

      safe_join([content_tag(:b, number_to_currency(fee_uk.to_f)), " ", t(".fee_for_uk_citizens")])
    end

    def international_fees
      fee_international = enrichment.fee_international
      return if fee_international.blank?

      safe_join([content_tag(:b, number_to_currency(fee_international.to_f)), " ", t(".fee_for_non_uk_citizens")])
    end

    NullEnrichment = Struct.new(:fee_uk_eu, :fee_international, keyword_init: true)

    def enrichment
      @enrichment ||= course.latest_published_enrichment || NullEnrichment.new
    end
  end
end
