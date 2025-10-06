# frozen_string_literal: true

module Find
  module Analytics
    class SavedCourseEvent < ApplicationEvent
      attr_accessor :candidate_id, :course_id

      def event_name
        :saved_course
      end

      def event_data
        {
          namespace: "find",
          candidate_id:,
          course_id:,
          timestamp: Time.zone.now.utc,
          referer: request.referer,
        }
      end
    end
  end
end
