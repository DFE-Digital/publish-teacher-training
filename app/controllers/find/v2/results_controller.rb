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

      private

      def search_courses_params
        params.permit(
          :can_sponsor_visa,
          :send_courses,
          :applications_open,
          :level,
          :funding,
          :minimum_degree_required,
          :location,
          :latitude,
          :longitude,
          :radius,
          :age_group,
          :degree_required,
          :university_degree_status,
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
