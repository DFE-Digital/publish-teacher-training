# frozen_string_literal: true

module Publish
  module Courses
    class LevelController < PublishController
      include CourseBasicDetailConcern

      private

      def error_keys
        %i[level is_send]
      end

      def current_step
        :level
      end
    end
  end
end
