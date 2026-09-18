module Support
  module Candidate
    class NotesController < ApplicationController
      def index
        @notes = @candidate.saved_courses.where.not(note: [nil, ""]).includes(course: { provider: :recruitment_cycle }).order(updated_at: :desc)
      end
    end
  end
end
