# frozen_string_literal: true

module Find
  module Results
    class SearchResultComponent < ViewComponent::Base
      include ::ViewHelper

      attr_reader :course

      def initialize(course:, filtered_by_location: false, has_sites: false)
        super
        @course = course.decorate
        @filtered_by_location = filtered_by_location
        @has_sites = has_sites
      end

      def filtered_by_location?
        @filtered_by_location
      end

      def has_sites?
        @has_sites
      end

      private

      def formatted_qualification
        t("find.qualification.description_with_abbreviation.#{course.qualification}.html")
      end

      def show_visa_sponsorship_and_degree_required?
        course.show_visa_sponsorship?
      end

      def degree_required_status
        {
          two_one: 'An undergraduate degree at class 2:1 or above, or equivalent',
          two_two: 'An undergraduate degree at class 2:2 or above, or equivalent',
          third_class: 'An undergraduate degree, or equivalent. This should be an honours degree (Third or above), or equivalent',
          not_required: 'An undergraduate degree, or equivalent'
        }[course.degree_grade&.to_sym || 'N/A']
      end

      def visa_sponsorship_status
        if !course.salaried? && course.can_sponsor_student_visa
          'Student visas can be sponsored'
        elsif course.salaried? && course.can_sponsor_skilled_worker_visa
          'Skilled Worker visas can be sponsored'
        else
          'Visas cannot be sponsored'
        end
      end

      def course_fee_value
        safe_join([formatted_uk_eu_fee_label, tag.br, formatted_international_fee_label])
      end

      def formatted_uk_eu_fee_label
        return if course.fee_uk_eu.blank?

        "UK students: #{number_to_currency(course.fee_uk_eu)}"
      end

      def formatted_international_fee_label
        return if course.fee_international.blank?

        "International students: #{number_to_currency(course.fee_international)}"
      end

      def no_fee?
        course.fee_international.blank? && course.fee_uk_eu.blank?
      end

      def accredited_provider
        return nil if course.accrediting_provider.blank?

        "QTS ratified by #{helpers.smart_quotes(course.accrediting_provider.provider_name)}"
      end
    end
  end
end
