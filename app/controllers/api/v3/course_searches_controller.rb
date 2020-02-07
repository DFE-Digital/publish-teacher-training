module API
  module V3
    class CourseSearchesController < API::V3::ApplicationController
      def index
        course_scope = CourseSearchService.call(filter: params[:filter])
        render jsonapi: paginate(course_scope)
      end
    end
  end
end
