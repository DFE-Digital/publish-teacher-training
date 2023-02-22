# frozen_string_literal: true

module Publish
  module Courses
    class ApprenticeshipController < FundingTypeController
      private

      def errors
        params.dig(:course, :funding_type) ? {} : { funding_type: ['Select if this is a teaching apprenticeship'] }
      end

      def current_step
        :apprenticeship
      end

      def section_key
        'Teaching apprenticeship'
      end
    end
  end
end
