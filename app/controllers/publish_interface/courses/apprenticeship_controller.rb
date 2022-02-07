module PublishInterface
  module Courses
    class ApprenticeshipController < PublishInterfaceController
      include CourseBasicDetailConcern

    private

      def current_step
        :apprenticeship
      end

      def error_keys
        %i[funding_type program_type]
      end
    end
  end
end
