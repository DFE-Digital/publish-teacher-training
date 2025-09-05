module Support
  class CandidatesController < ApplicationController
    before_action :set_candidate, only: %i[details saved_courses]

    def index
      @pagy, @candidates = pagy(filtered_candidates)
    end

    def details; end

    def saved_courses
      @saved_courses = @candidate.saved_courses.order(created_at: :desc)
    end

  private

    def filtered_candidates
      Support::Filter.call(model_data_scope: Candidate.order(:email_address), filter_params:)
    end

    def filter_params
      @filter_params ||= params.except(:commit).permit(:text_search, :page, :commit)
    end

    def set_candidate
      @candidate = Candidate.find(params[:id])
    end
  end
end
