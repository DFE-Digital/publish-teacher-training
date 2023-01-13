module Find
  class ResultsController < ApplicationController
    before_action :render_feedback_component
    FILTERS = {
      "lat" => "latitude",
      "lng" => "longitude",
      "rad" => "radius",
      "query" => "provider.provider_name",
      "hasvacancies" => "has_vacancies",
    }.freeze

    STUDY_FILTERS = {
      "parttime" => "part_time",
      "fulltime" => "full_time",
    }.freeze

    def index
      filter_old_find_params
      binding.pry
      @results_view = ResultsView.new(query_parameters: request.query_parameters)
      @filters_view = ResultFilters::FiltersView.new(params:)
      @courses = @results_view.courses.page params[:page]
      @number_of_courses_string = @results_view.number_of_courses_string
    end

  private

    def filter_old_find_params
      request.query_parameters[:sortby] = "distance" if request.query_parameters[:sortby] == "2"

      if FILTERS.keys & request.query_parameters.keys
        (FILTERS.keys & request.query_parameters.keys).each do |k|
          request.query_parameters[FILTERS[k]] = request.query_parameters.delete k
        end
      end

      if STUDY_FILTERS.keys & request.query_parameters.keys
        (STUDY_FILTERS.keys & request.query_parameters.keys).each do |k|
          if request.query_parameters[k] == "true"
            request.query_parameters[:study_type] |= STUDY_FILTERS[k]
            request.query_parameters.delete(k)
          end
        end
      end

      #      if request.query_parameters[:fulltime] == "true"
      #        request.query_parameters[:study_type] |= ["full_time"]
      #        request.query_parameters.delete(:fulltime)
      #      end
      #      if request.query_parameters[:parttime] == "true"
      #        request.query_parameters[:study_type] |= ["part_time"]
      #        request.query_parameters.delete(:partime)
      #      end
    end
  end
end
