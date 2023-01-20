module Find
  class ResultsController < ApplicationController
    before_action :render_feedback_component

    def index
      matched_params = MatchOldParams.call(request.query_parameters)

      @results_view = ResultsView.new(query_parameters: matched_params)
      @filters_view = ResultFilters::FiltersView.new(params: matched_params)
      @courses = @results_view.courses.page params[:page]
      @number_of_courses_string = @results_view.number_of_courses_string
    end
  end
end
