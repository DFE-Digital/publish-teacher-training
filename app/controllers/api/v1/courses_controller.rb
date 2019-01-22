module Api
  module V1
    class CoursesController < ApplicationController
      def index
        recruitment_cycle_year = params[:recruitment_cycle_year]
        if recruitment_cycle_year.present?
          if recruitment_cycle_year == "2019"
            @courses = Course.all.includes(:sites, :provider, :site_statuses)
          else
            return render plain: "courses for year '#{recruitment_cycle_year}' not found", status: :not_found
          end
        else
          @courses = Course.all.includes(:sites, :provider, :site_statuses)
        end
        paginate json: @courses
      end
    end
  end
end
