module Api
  module V1
    class CoursesController < ApplicationController
      def index
        @courses = Course.all.includes(:sites, :provider, :site_statuses)
        paginate json: @courses
      end
    end
  end
end
