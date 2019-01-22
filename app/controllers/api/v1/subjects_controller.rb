module Api
  module V1
    class SubjectsController < ApplicationController
      def index
        recruitment_cycle_year = params[:recruitment_cycle_year]
        if recruitment_cycle_year.present?
          if recruitment_cycle_year == "2019"
            @subjects = Subject.all
          else
            return render plain: "subjects for year '#{recruitment_cycle_year}' not found", status: :not_found
          end
        else
          @subjects = Subject.all
        end
        paginate json: @subjects
      end
    end
  end
end
