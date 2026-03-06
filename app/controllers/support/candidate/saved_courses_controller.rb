module Support
  module Candidate
    class SavedCoursesController < ApplicationController
      def index
        @saved_courses = @candidate.saved_courses.includes(course: :provider).order(created_at: :desc)
      end
    end
  end
end
