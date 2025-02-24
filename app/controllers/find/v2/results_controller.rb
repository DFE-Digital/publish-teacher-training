# frozen_string_literal: true

module Find
  module V2
    class ResultsController < Find::ApplicationController
      def index
        coordinates = Geolocation::CoordinatesQuery.new(params[:location]).call

        @search_courses_form = ::Courses::SearchForm.new(search_courses_params.merge(coordinates))
        @search_params = @search_courses_form.search_params
        @courses_query = ::Courses::Query.new(params: @search_params.dup)
        @courses = @courses_query.call
        @courses_count = @courses.unscope(:order, :group).distinct.count(:id)
        @pagy, @results = pagy(@courses, count: @courses_count)

        Find::Analytics::SearchResultsEvent.new(
          request:,
          total: @courses_count,
          page: @pagy.page,
          search_params: @search_params,
          track_params: params.permit(:utm_source, :utm_medium),
          results: @results
        ).send_event
      end

      private

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
          study_types: [],
          qualifications: [],
          qualification: [],
          funding: []
        )
      end
    end
  end
end
