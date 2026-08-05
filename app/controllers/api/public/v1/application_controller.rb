# frozen_string_literal: true

module API
  module Public
    module V1
      class ApplicationController < PublicAPIController
        include PagyPagination

        def current_namespace
          "publish_api"
        end

      private

        def recruitment_cycle
          year = params[:recruitment_cycle_year]
          @recruitment_cycle ||= RecruitmentCycle.find_by(year:) || RecruitmentCycle.current_recruitment_cycle!
        end

        def schools_remodelled
          recruitment_cycle.after?(Settings.schools_remodel_cycle_year)
        end
      end
    end
  end
end
