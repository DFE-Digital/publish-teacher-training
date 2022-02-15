module Publish
  module Courses
    class StartDateController < PublishController
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
