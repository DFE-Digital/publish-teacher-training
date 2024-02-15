# frozen_string_literal: true

module API
  module Public
    module V1
      class ApplicationController < PublicAPIController
        include PagyPagination

        private

        def recruitment_cycle
          year = params[:recruitment_cycle_year]
          @recruitment_cycle ||= RecruitmentCycle.find_by(year:) || RecruitmentCycle.current_recruitment_cycle
        end
      end
    end
  end
end
