# frozen_string_literal: true

module Find
  module V2
    class ResultsController < Find::ApplicationController
      def index
        @search_courses_form = ::Courses::SearchForm.new(search_courses_params)
        @search_params = @search_courses_form.search_params

        @courses = ::Courses::Query.call(params: @search_params)
        @courses_count = @courses.unscope(:order, :group).distinct.count(:id)

        @pagy, @results = pagy(@courses, count: @courses_count)
      end

      def location_suggestions
        render json: {
          suggestions: [
            {
              name: "London",
              place_id: "AhIJ2dGMjMMEdkgRqVqzRfvXh5M",
              latitude: 51.5007,
              longitude: -0.1246,
              location_types: ["landmark", "point_of_interest"]
            },
            {
              name: "Buckingham Palace",
              place_id: "BhIJ4dD4QgmEdkgRm2QR8D9T0j8",
              latitude: 52.5014,
              longitude: -0.2419,
              location_types: ["tourist_attraction", "point_of_interest", "establishment"]
            },
            {
              name: "London Eye",
              place_id: "ChIJ4dD4QgmEadkgRm2QR8D9T0j8",
              latitude: 53.5014,
              longitude: -0.3419,
              location_types: ["tourist_attraction", "point_of_interest", "establishment"]
            },
            {
              name: "National Museum",
              place_id: "DhIJ4dD4QgmaEdkgRm2QR8D9T0j8",
              latitude: 54.5014,
              longitude: -0.4419,
              location_types: ["tourist_attraction", "point_of_interest", "establishment"]
            }
          ]
        }
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
