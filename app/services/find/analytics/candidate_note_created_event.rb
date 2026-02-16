# frozen_string_literal: true

module Find
  module Analytics
    class CandidateNoteCreatedEvent < ApplicationEvent
      attr_accessor :course_id, :saved_course_id, :note

      def event_name
        :candidate_note_created
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
