# frozen_string_literal: true

module Find
  class ResultsController < ApplicationController
    before_action :render_feedback_component

    def index
      matched_params = MatchOldParams.call(request.query_parameters)

      @search_params = matched_params

      @results_view = ResultsView.new(query_parameters: matched_params)
      @filters_view = ResultFilters::FiltersView.new(params: matched_params)
      @pagy, @courses = pagy(@results_view.courses)
      @number_of_courses_string = @results_view.number_of_courses_string

      track_search_results(number_of_results: @results_view.course_count,
                           course_codes: @results_view.courses.pluck(:course_code).uniq)
    end

    private

    def track_search_results(number_of_results:, course_codes:)
      Find::ResultsTracking.new(request:).track_search_results(number_of_results:, course_codes:)
    end
  end
end
