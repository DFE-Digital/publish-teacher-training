# frozen_string_literal: true

module Find
  module Results
    class SearchResultComponent < ViewComponent::Base
      include ::ViewHelper

      attr_reader :course

      delegate :age_range_in_years_and_level, :course_length_with_study_mode, to: :course

      def initialize(course:, filtered_by_location: false, sites_count: 0)
        super
        @course = course.decorate
        @filtered_by_location = filtered_by_location
        @sites_count = sites_count
      end

      def filtered_by_location?
        @filtered_by_location
      end

      def has_sites?
        @sites_count.positive?
      end

      def coure_title_link
        t(
          '.course_title_html',
          course_path: find_course_path(provider_code: course.provider_code, course_code: course.course_code),
          provider_name: helpers.smart_quotes(course.provider.provider_name),
          course_name: course.name_and_code
        )
      end

      def location_label
        t('.location', count: @sites_count)
      end

      private

      def formatted_qualification
        t("find.qualification.description_with_abbreviation.#{course.qualification}.html")
      end

      def show_visa_sponsorship_and_degree_required?
        course.show_visa_sponsorship?
      end

      def degree_required_status
        course.degree_grade_content || 'N/A'
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
