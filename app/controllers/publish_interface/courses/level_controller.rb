module PublishInterface
  module Courses
    class LevelController < PublishInterfaceController
      include CourseBasicDetailConcern

  private

      def error_keys
        [:level]
      end

      def current_step
        :level
      end
    end
  end
end
