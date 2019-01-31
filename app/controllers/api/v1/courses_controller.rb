module Api
  module V1
    class CoursesController < ApplicationController
      def index
        @courses = Course.includes(:sites, :provider, :site_statuses, :subjects)
        paginate json: @courses
      end
    end
  end
end
