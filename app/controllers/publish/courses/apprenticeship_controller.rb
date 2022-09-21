module Publish
  module Courses
    class ApprenticeshipController < FundingTypeController
    private

      def current_step
        :apprenticeship
      end
    end
  end
end
