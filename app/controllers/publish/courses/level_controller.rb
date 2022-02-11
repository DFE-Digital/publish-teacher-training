module Publish
  module Courses
    class LevelController < PublishController
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
