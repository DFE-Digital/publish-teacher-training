# frozen_string_literal: true

module Find
  module Analytics
    class CandidateNoteUndoneEvent < ApplicationEvent
      attr_accessor :course_id, :saved_course_id, :note

      def event_name
        :candidate_note_undone
      end

      def namespace
        "find"
      end

      def event_data
        {
          data: {
            course_id:,
            saved_course_id:,
            note:,
            timestamp: Time.zone.now.utc,
          },
        }
      end
    end
  end
end
