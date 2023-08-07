# frozen_string_literal: true

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

      def section_key
        "Course start date"
      end
    end
  end
end
