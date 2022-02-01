module PublishInterface
  module Courses
    class StartDateController < PublishInterfaceController
      include CourseBasicDetailConcern

    private

      def current_step
        :start_date
      end

      def error_keys
        [:start_date]
      end
    end
  end
end
