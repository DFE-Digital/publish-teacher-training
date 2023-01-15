module Find
  class ResultsController < ApplicationController
    before_action :render_feedback_component
    FILTERS = {
      "senCourses" => "send_courses",
      "lat" => "latitude",
      "lng" => "longitude",
      "rad" => "radius",
      "query" => "provider.provider_name",
      "hasvacancies" => "has_vacancies",
      "subject_codes" => "subjects",
    }.freeze

    STUDY_FILTERS = {
      "parttime" => "part_time",
      "fulltime" => "full_time",
    }.freeze

    QAULIFICATION_FILTERS = {
      "Other" => "pgce pgde",
      "PgdePgceWithQts" => "pgce_with_qts",
      "QtsOnly" => "qts",
    }.freeze

    def index
      binding.pry
      match_old_find_params
      @results_view = ResultsView.new(query_parameters: request.query_parameters)

      @filters_view = ResultFilters::FiltersView.new(params: request.query_parameters)
      @courses = @results_view.courses.page params[:page]
      @number_of_courses_string = @results_view.number_of_courses_string
    end

  private

    def match_old_find_params
      request.query_parameters[:sortby] = "distance" if request.query_parameters[:sortby] == "2"
      request.query_parameters[:funding] = "salary" if request.query_parameters[:funding] == "8"

      if request.query_parameters[:qualifications]
        request.query_parameters[:qualification] = request.query_parameters.delete :qualifications
        QAULIFICATION_FILTERS.each do |k, v|
          if request.query_parameters[:qualification].include?(k)
            request.query_parameters[:qualification] -= [k]
            request.query_parameters[:qualification] |= [v]
          end
        end
      end

      if FILTERS.keys & request.query_parameters.keys
        (FILTERS.keys & request.query_parameters.keys).each do |k|
          request.query_parameters[FILTERS[k]] = request.query_parameters.delete k
        end
      end

      if STUDY_FILTERS.keys & request.query_parameters.keys
        (STUDY_FILTERS.keys & request.query_parameters.keys).each do |k|
          next unless request.query_parameters[k] == "true"

          request.query_parameters[:study_type] ||= []
          request.query_parameters[:study_type] |= [STUDY_FILTERS[k]]
          request.query_parameters.delete(k)
        end
      end
    end
  end
end
