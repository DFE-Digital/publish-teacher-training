module Api
  module V1
    class CoursesController < ApplicationController
      def index
        @courses = Course.all
        paginate json: @courses
      end
    end
  end
end
