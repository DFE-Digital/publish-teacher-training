# frozen_string_literal: true

module Find
  class ResultsController < Find::ApplicationController
    after_action :store_result_fullpath_for_backlinks, :send_analytics_event, only: [:index]

    def index
      coordinates = Geolocation::CoordinatesQuery.new(location_params).call

      @search_courses_form = ::Courses::SearchForm.new(search_courses_params.merge(coordinates))
      @search_params = @search_courses_form.search_params
      @courses_query = ::Courses::Query.new(params: @search_params.dup)
      @courses = @courses_query.call
      @courses_count = @courses_query.count

      @pagy, @results = pagy(@courses, count: @courses_count, page:)
    end

  private

    def send_analytics_event
      Find::Analytics::SearchResultsEvent.new(
        request:,
        total: @courses_count,
        page: @pagy.page,
        search_params: @search_params,
        track_params: params.permit(:utm_source, :utm_medium),
        results: @results,
      ).send_event
    end

    def search_courses_params
      params.permit(
        :'provider.provider_name',
        :age_group,
        :applications_open,
        :can_sponsor_visa,
        :degree_required,
        :funding,
        :latitude,
        :level,
        :location,
        :longitude,
        :lq,
        :minimum_degree_required,
        :order,
        :provider_code,
        :provider_name,
        :radius,
        :engineers_teach_physics,
        :send_courses,
        :sortby,
        :subject_code,
        :subject_name,
        :university_degree_status,
        subjects: [],
        start_date: [],
        study_type: [],
        study_types: [],
        qualifications: [],
        qualification: [],
        funding: [],
      )
    end

    def location_params
      params[:location] || params[:lq]
    end

    def store_result_fullpath_for_backlinks
      session[:results_path] = request.fullpath
    end

    def page
      params[:page].to_i.clamp(1..)
    end
  end
end
