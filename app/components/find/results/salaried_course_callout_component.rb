# frozen_string_literal: true

module Find
  module Results
    class SalariedCourseCalloutComponent < ViewComponent::Base
      SALARIED_FUNDING = %w[salary apprenticeship].freeze

      def initialize(funding:, subject_codes:)
        super()
        @funding = Array(funding)
        @subject_codes = Array(subject_codes)
      end

      def render?
        FeatureFlag.active?(:bursaries_and_scholarships_announced) &&
          @funding.intersect?(SALARIED_FUNDING) &&
          @subject_codes.intersect?(Subject.secondary_subject_codes_with_bursary_or_scholarship)
      end
    end
  end
end
