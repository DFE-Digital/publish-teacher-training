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
          track_params:,
          results: @results
        ).send_event
      end

      private

      def search_courses_params
        params.permit(
          :can_sponsor_visa,
          :send_courses,
          :applications_open,
          :level,
          :funding,
          :minimum_degree_required,
          :age_group,
          :provider_code,
          :'provider.provider_name',
          :provider_name,
          :location,
          :latitude,
          :longitude,
          :radius,
          :order,
          :age_group,
          :degree_required,
          :university_degree_status,
          :sortby,
          :subject_code,
          :subject_name,
          subjects: [],
          study_types: [],
          qualifications: [],
          qualification: [],
          funding: []
        )
      end

      def track_params
        if request.referer.present?
          params.permit(:utm_source, :utm_medium)
        else
          { utm_source: 'results', utm_medium: 'no_referer' }
        end
      end
    end
  end
end
