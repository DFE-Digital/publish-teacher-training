# frozen_string_literal: true

module Find
  class ResultsController < ApplicationController
    before_action :render_feedback_component

    def index
      matched_params = MatchOldParams.call(request.query_parameters)
                                     .merge(
                                       keywords: request.query_parameters[:keywords],
                                       **geocode_params_for(request.query_parameters[:lq])
                                     )

      @results_view = ResultsView.new(query_parameters: matched_params)
      @filters_view = ResultFilters::FiltersView.new(params: matched_params)
      @courses = @results_view.courses.page(params[:page]).per(10)
      @number_of_courses_string = @results_view.number_of_courses_string

      track_search_results(number_of_results: @results_view.course_count,
                           course_codes: @courses.pluck(:course_code).uniq)
    end

    def count
      matched_params = MatchOldParams.call(request.query_parameters)
                                     .merge(
                                       keywords: request.query_parameters[:keywords],
                                       **geocode_params_for(request.query_parameters[:lq])
                                     )

      @filters_view = ResultFilters::FiltersView.new(params: matched_params)
      @results_view = ResultsView.new(query_parameters: matched_params)
    end

    private

    def track_search_results(number_of_results:, course_codes:)
      Find::ResultsTracking.new(request:).track_search_results(number_of_results:, course_codes:)
    end

    def geocode_params_for(query)
      return {} if query.blank?

      results = geocoder_result(query)
      return {} unless results

      {
        l: '1',
        latitude: results.latitude,
        longitude: results.longitude,
        loc: results.address,
        lq: query,
        c: country(results),
        sortby: ResultsView::DISTANCE,
        radius: request.query_parameters.fetch(:radius, ResultsView::MILES)
      }
    end

    def geocoder_result(query)
      Rails.cache.fetch("geocoder/#{query}", expires_in: 4.hours) do
        Geocoder.search(query, components: 'country:UK').first
      end
    end

    def country(results)
      flattened_results = results.address_components.map(&:values).flatten
      countries = [*DEVOLVED_NATIONS, 'England'].flatten

      countries.each { |country| return country if flattened_results.include?(country) }
    end
  end
end
