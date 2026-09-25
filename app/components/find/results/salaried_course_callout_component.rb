# frozen_string_literal: true

module Find
  module Results
    class SalariedCourseCalloutComponent < ViewComponent::Base
      SALARIED_FUNDING = %w[salary apprenticeship].freeze

      def initialize(funding:, subject_codes:, page:)
        super()
        @funding = Array(funding)
        @subject_codes = Array(subject_codes)
        @page = page
      end

      def render?
        @page == 1 &&
          @funding.intersect?(SALARIED_FUNDING) &&
          @subject_codes.intersect?(Subject.secondary_subject_codes_with_bursary)
      end
    end
  end
end
