module API
  module V3
    class CourseSearchesController < ApplicationController
      def index
        render jsonapi: CourseSearch.call(filter: params[:filter], recruitment_cycle_year: params[:recruitment_cycle_year])
      end
    end
  end
end
