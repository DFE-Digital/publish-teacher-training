# frozen_string_literal: true

module Find
  module V2
    class ResultsController < Find::ApplicationController
      before_action :enforce_basic_auth

      def index
        @course_search_form = CourseSearchForm.new(params.permit(:can_sponsor_visa))
        @courses = CoursesQuery.call(@course_search_form.search_params)

        @pagy, @results = pagy(@courses)
      end

      def enforce_basic_auth
        authenticate_or_request_with_http_basic do |username, password|
          BasicAuthenticable.authenticate(username, password)
        end
      end
    end
  end
end
