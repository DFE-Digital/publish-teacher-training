module Find
  class ResultsController < ApplicationController
    before_action :render_feedback_component

    def index
      @results_view = ResultsView.new(query_parameters: request.query_parameters)
      @filters_view = ResultFilters::FiltersView.new(params:)
      @courses = @results_view.courses.page params[:page]
      @number_of_courses_string = @results_view.number_of_courses_string
    end
  end
end
