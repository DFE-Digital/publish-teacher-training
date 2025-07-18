module Support
  class CandidatesController < ApplicationController
    def index
      @candidates = Candidate.order(created_at: :desc)
    end
  end
end
