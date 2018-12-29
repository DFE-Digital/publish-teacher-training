module Api
  module V1
    class CoursesController < ActionController::API
      def index
        @courses = Course.all
        paginate json: @courses
      end
    end
  end
end
