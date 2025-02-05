# frozen_string_literal: true

module Find
  module V2
    class ResultsController < Find::ApplicationController
      def index
        @coordinates = Geolocation::Resolver.new(
          query: params[:location],
          place_id: params[:location_id]
        ).call

        @search_courses_form = ::Courses::SearchForm.new(search_courses_params)
        @search_params = @search_courses_form.search_params.merge(@coordinates)

        @courses = ::Courses::Query.call(params: @search_params)
        @courses_count = @courses.unscope(:order, :group).distinct.count(:id)

        @pagy, @results = pagy(@courses, count: @courses_count)
      end

      private

      def location_params
        params.permit(:location_id, :location).to_h.symbolize_keys
      end

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
          subjects: [],
          study_types: [],
          qualifications: [],
          qualification: [],
          funding: []
        )
      end
    end
  end
end
