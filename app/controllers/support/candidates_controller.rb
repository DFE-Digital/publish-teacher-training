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
      scope = Support::Filter.call(model_data_scope: Candidate.all, filter_params:)
      order_scope(scope)
    end

    def order_scope(scope)
      case params[:sort]
      when "created_at_desc"
        scope.order(created_at: :desc)
      when "created_at_asc"
        scope.order(created_at: :asc)
      else
        scope.order(:email_address)
      end
    end

    def filter_params
      @filter_params ||= params.except(:commit).permit(:text_search, :page, :commit, :sort)
    end

    def set_candidate
      @candidate = Candidate.find(params[:id])
    end
  end
end
