# frozen_string_literal: true

module Find
  module Results
    class SearchResultComponent < ViewComponent::Base
      include ::ViewHelper

      attr_reader :course, :sites_count

      delegate :age_range_in_years_and_level,
               :course_length_with_study_mode,
               :no_fee?, to: :course

      def initialize(course:, results_view:, filtered_by_location: false)
        super
        @course = course.decorate
        @filtered_by_location = filtered_by_location
        @sites_count = results_view.sites_count(course)
        @results_view = results_view
        @search_params = results_view.query_parameters.to_query
      end

      def filtered_by_location?
        @filtered_by_location
      end

      def has_sites?
        sites_count.positive?
      end

      def course_title_link
        t(
          '.course_title_html',
          course_path: find_course_path(provider_code: course.provider_code, course_code: course.course_code, search_params: @search_params),
          provider_name: helpers.smart_quotes(course.provider.provider_name),
          course_name: course.name_and_code
        )
      end

      def location_label
        if course.fee_based?
          t('.fee_based.location', count: sites_count)
        else
          t('.salary_based.location', count: sites_count)
        end
      end

      def location_name
        @results_view.query_parameters['lq']
      end

      def school_term
        if course.fee?
          'placement'
        else
          'employing'
        end
      end

      def site_distance
        @results_view.site_distance(course)
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

      def accredited_provider
        return nil if course.accrediting_provider.blank?

        "QTS ratified by #{helpers.smart_quotes(course.accrediting_provider.provider_name)}"
      end
    end
  end
end
