# frozen_string_literal: true

module API
  module Public
    module V1
      class ApplicationController < PublicAPIController
        include PagyPagination

        private

        def recruitment_cycle
          @recruitment_cycle ||= begin
            year = params.require(:recruitment_cycle_year)

            case year
            when 'current'
              RecruitmentCycle.current_recruitment_cycle
            else
              RecruitmentCycle.find_by!(year:)
            end
          end
        end
      end
    end
  end
end
