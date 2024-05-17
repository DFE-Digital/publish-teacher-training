# frozen_string_literal: true

module Find
  class ResultsController < ApplicationController
    before_action :render_feedback_component

    def index
      matched_params = MatchOldParams.call(request.query_parameters)

      @results_view = ResultsView.new(query_parameters: matched_params)
      @filters_view = ResultFilters::FiltersView.new(params: matched_params)
      @courses = @results_view.courses.page params[:page]
      @number_of_courses_string = @results_view.number_of_courses_string

      track_search_results(number_of_results: @results_view.course_count,
                           course_codes: @courses.pluck(:course_code).uniq)
    end

    private

    def track_search_results(number_of_results:, course_codes:)
      Find::ResultsTracking.new(request:).track_search_results(number_of_results:, course_codes:)
    end
  end
end
