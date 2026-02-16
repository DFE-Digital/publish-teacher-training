# frozen_string_literal: true

module Find
  module Analytics
    class CandidateNoteUpdatedEvent < ApplicationEvent
      attr_accessor :course_id, :saved_course_id, :note_before_edit, :note_after_edit

      def event_name
        :candidate_note_updated
      end

      def namespace
        "find"
      end

      def event_data
        {
          data: {
            course_id:,
            saved_course_id:,
            note_before_edit:,
            note_after_edit:,
            timestamp: Time.zone.now.utc,
          },
        }
      end
    end
  end
end
