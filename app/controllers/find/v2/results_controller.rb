# frozen_string_literal: true

module Find
  module V2
    class ResultsController < Find::ApplicationController
      def index
        @search_courses_form = SearchCoursesForm.new(search_courses_params)
        @courses = CoursesQuery.call(params: @search_courses_form.search_params)
        @courses_count = @courses.count

        @pagy, @results = pagy(@courses)
      end

      private

      def search_courses_params
        params.permit(
          :can_sponsor_visa,
          :send_courses,
          :applications_open,
          :level,
          :funding,
          :age_group,
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
