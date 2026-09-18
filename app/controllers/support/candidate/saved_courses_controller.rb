module Support
  module Candidate
    class SavedCoursesController < ApplicationController
      def index
        @saved_courses = @candidate.saved_courses.includes(course: { provider: :recruitment_cycle }).order(created_at: :desc)
      end
    end
  end
end
