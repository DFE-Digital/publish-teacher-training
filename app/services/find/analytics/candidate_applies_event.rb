# frozen_string_literal: true

module Find
  module Analytics
    class CandidateAppliesEvent < ApplicationEvent
      attr_accessor :course_id

      def event_name
        :candidate_applies
      end

      def namespace
        "find"
      end

      def event_data
        {
          data: {
            course_id:,
            was_course_saved: was_course_saved?,
            timestamp: Time.zone.now.utc,
          },
        }
      end

      def was_course_saved?
        current_user.present? && SavedCourse.exists?(candidate_id: current_user.id, course_id:)
      end
    end
  end
end
