# frozen_string_literal: true

module Find
  module Analytics
    class RemoveSavedCourseEvent < ApplicationEvent
      attr_accessor :candidate_id, :course_id

      def event_name
        :removed_saved_course
      end

      def namespace
        "find"
      end

      def event_data
        {
          data: {
            candidate_id:,
            course_id:,
            timestamp: Time.zone.now.utc,
            referer: request.referer,
          },
        }
      end
    end
  end
end
