module Publish
  module Courses
    class ApprenticeshipController < PublishController
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
