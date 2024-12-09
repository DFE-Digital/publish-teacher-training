# frozen_string_literal: true

module Find
  module V2
    class ResultsController < Find::ApplicationController
      before_action :enforce_basic_auth

      def index
        @courses = CoursesQuery.call(params:)

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
