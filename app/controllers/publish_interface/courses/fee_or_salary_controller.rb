module PublishInterface
  module Courses
    class FeeOrSalaryController < PublishInterfaceController
      include CourseBasicDetailConcern

    private

      def current_step
        :fee_or_salary
      end

      def error_keys
        %i[funding_type program_type]
      end
    end
  end
end
