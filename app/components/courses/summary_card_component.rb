# frozen_string_literal: true

module Courses
  class SummaryCardComponent < ViewComponent::Base
    attr_reader :course, :search_params, :available_placements_count, :minimum_distance_to_search_location

    def initialize(course:, search_params:)
      @course = course
      @search_params = search_params
      @available_placements_count = course.available_placements_count

      super
    end

    def title
      govuk_link_to(find_course_path(provider_code: course.provider_code, course_code: course.course_code), class: 'govuk-link govuk-!-font-size-24') do
        safe_join(
          [
            content_tag(:span, course.provider_name, class: 'app-search-result__provider-name'),
            content_tag(:span, course.name_and_code, class: 'app-search-result__course-name')
          ]
        )
      end
    end

    def location_key
      t(".location_key.#{course.funding}", count: @available_placements_count)
    end

    def location_value
      return t('.location_value.not_listed') if @available_placements_count.zero?

      if search_by_location?
        safe_join(
          [
            t(
              '.location_value.distance',
              school_term:,
              distance: content_tag(:span, pluralize(course.minimum_distance_to_search_location, 'mile'), class: 'govuk-!-font-weight-bold'),
              location: content_tag(:span, sanitize(@search_params[:location]), class: 'govuk-!-font-weight-bold')
            ).html_safe,
            content_tag(
              :div,
              t(
                '.location_value.distance_hint_html',
                school_term:,
                count: @available_placements_count
              ),
              class: 'govuk-hint govuk-!-font-size-16'
            )
          ]
        )
      else
        t(
          '.location_value.potential_schools',
          count: @available_placements_count,
          school_term:
        )
      end
    end

    def fee_key
      t('.fee_key')
    end

    def fee_value
      case course.funding
      when 'salary', 'apprenticeship'
        t(".fee_value.#{course.funding}")
      else
        [
          fee_content,
          fee_hint
        ].join.html_safe
      end
    end

    def length_key
      t('.length_key')
    end

    def length_value
      course_length = course.enrichment_attribute(:course_length).to_s
      translated_course_length = t(".length_value.#{course_length}", default: course_length)

      [translated_course_length, course.study_mode.humanize.downcase].join(' - ')
    end

    def show_age_group_row?
      course.age_range_in_years.present?
    end

    def age_group_key
      t('.age_group_key')
    end

    def age_group_value
      "#{course.level.humanize} - #{course.age_range_in_years.humanize}"
    end

    def qualification_key
      t('.qualification_key')
    end

    def qualification_value
      t(".qualification_value.#{course.qualification}_html")
    end

    def degree_requirements_key
      t('.degree_requirements_key')
    end

    def degree_requirements_value
      content = t(".degree_requirements_value.#{course.degree_type}.#{course.degree_grade}")
      hint = t(".degree_requirements_hint.#{course.degree_grade}.html") unless course.undergraduate_degree_type?

      [
        content,
        hint
      ].join.html_safe
    end

    def visa_sponsorship_key
      t('.visa_sponsorship_key')
    end

    def visa_sponsorship_value
      t(".visa_sponsorship_value.#{course.visa_sponsorship}")
    end

    private

    def school_term
      t(".location_value.school_term.#{course.funding}", default: t('.location_value.school_term.default'))
    end

    def search_by_location?
      @search_params[:location].present?
    end

    def fee_content
      fees = [uk_fees, international_fees].compact_blank

      safe_join(fees, tag.br)
    end

    def uk_fees(fee_uk = course.enrichment_attribute(:fee_uk_eu))
      t('.fee_value.fee.uk_fees_html', value: content_tag(:b, number_to_currency(fee_uk.to_f)))
    end

    def international_fees(fee_international = course.enrichment_attribute(:fee_international))
      return if fee_international.blank?

      t('.fee_value.fee.international_fees_html', value: content_tag(:b, number_to_currency(fee_international.to_f)))
    end

    def fee_hint
      return nil if hide_fee_hint?

      if financial_incentive.bursary_amount.present? && financial_incentive.scholarship.present?
        t(
          '.fee_value.fee.hint.bursaries_and_scholarship_html',
          bursary_amount: number_to_currency(financial_incentive.bursary_amount),
          scholarship_amount: number_to_currency(financial_incentive.scholarship)
        )
      elsif financial_incentive.bursary_amount.present?
        t(
          '.fee_value.fee.hint.bursaries_only_html',
          bursary_amount: number_to_currency(financial_incentive.bursary_amount)
        )
      elsif financial_incentive.scholarship.present?
        t(
          '.fee_value.fee.hint.scholarship_only_html',
          scholarship_amount: number_to_currency(financial_incentive.scholarship)
        )
      end
    end

    def hide_fee_hint?
      !bursary_and_scholarship_flag_active_or_preview? || (search_by_visa_sponsorship? && (!physics? && !languages?)) || financial_incentive.blank?
    end

    def search_by_visa_sponsorship?
      @search_params[:can_sponsor_visa].present?
    end

    PHYSICS_SUBJECT = 'Physics'

    def physics?
      main_subject&.subject_name == PHYSICS_SUBJECT
    end

    LANGUAGE_SUBJECTS = [
      'Ancient Greek',
      'Ancient Hebrew',
      'English',
      'English as a second or other language',
      'French',
      'German',
      'Italian',
      'Japanese',
      'Latin',
      'Mandarin',
      'Modern Languages',
      'Modern languages (other)',
      'Russian',
      'Spanish'
    ].freeze

    def languages?
      main_subject&.subject_name.in?(LANGUAGE_SUBJECTS)
    end

    def financial_incentive
      @financial_incentive ||= main_subject&.financial_incentive
    end

    def main_subject
      @main_subject ||= Subject.find_by(id: course.master_subject_id)
    end

    def bursary_and_scholarship_flag_active_or_preview?
      FeatureFlag.active?(:bursaries_and_scholarships_announced)
    end
  end
end
