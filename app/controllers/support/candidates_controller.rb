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

    ORDER_MAP = {
      "created_at_desc" => { created_at: :desc },
      "created_at_asc" => { created_at: :asc },
    }.freeze

    def filtered_candidates
      scope = Support::Filter.call(model_data_scope: Candidate.all, filter_params:)
      apply_sort(scope)
    end

    def apply_sort(scope)
      scope.order(ORDER_MAP.fetch(params[:sort], :email_address))
    end

    def filter_params
      @filter_params ||= params.except(:commit).permit(:text_search, :page, :commit, :sort)
    end

    def set_candidate
      @candidate = Candidate.find(params[:id])
    end
  end
end
