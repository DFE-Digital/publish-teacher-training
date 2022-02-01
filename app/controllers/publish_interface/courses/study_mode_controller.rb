module PublishInterface
  module Courses
    class StudyModeController < PublishInterfaceController
      include CourseBasicDetailConcern

    private

      def current_step
        :full_or_part_time
      end

      def errors
        params.dig(:course, :study_mode) ? {} : { study_mode: ["Pick full time, part time or full time and part time"] }
      end
    end
  end
end
