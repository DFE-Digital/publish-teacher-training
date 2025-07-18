module Support
  class CandidatesController < ApplicationController
    def index
      @pagy, @candidates = pagy(Candidate.order(created_at: :desc))
    end
  end
end
