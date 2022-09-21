module Publish
  module Courses
    class FeeOrSalaryController < FundingTypeController
    private

      def current_step
        :fee_or_salary
      end
    end
  end
end
