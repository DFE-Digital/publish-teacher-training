# frozen_string_literal: true

module Find
  module V2
    class ResultsController < Find::ApplicationController
      before_action :enforce_basic_auth

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
          :further_education,
          :funding,
          study_types: [],
          qualifications: [],
          funding: []
        )
      end

      def enforce_basic_auth
        authenticate_or_request_with_http_basic do |username, password|
          BasicAuthenticable.authenticate(username, password)
        end
      end
    end
  end
end
