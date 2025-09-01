module Support
  class CandidatesController < ApplicationController
    before_action :set_candidate, only: %i[details saved_courses]

    def index
      @pagy, @candidates = pagy(Candidate.order(created_at: :desc))
    end

    def details; end

    def saved_courses
      @saved_courses = @candidate.saved_courses.order(created_at: :desc)
    end

  private

    def set_candidate
      @candidate = Candidate.find(params[:id])
    end
  end
end
