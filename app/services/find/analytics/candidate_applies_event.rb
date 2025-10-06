# frozen_string_literal: true

module Find
  module Analytics
    class CandidateAppliesEvent < ApplicationEvent
      attr_accessor :candidate_id, :course_id

      def event_name
        :candidate_applies
      end

      def event_data
        {
          namespace: "find",
          candidate_id:,
          course_id:,
          was_course_saved: was_course_saved?,
          timestamp: Time.zone.now.utc,
        }
      end

      def was_course_saved?
        candidate_id.present? && SavedCourse.exists?(candidate_id:, course_id:)
      end
    end
  end
end
