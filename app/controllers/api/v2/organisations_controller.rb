module API
  module V2
    class OrganisationsController < API::V2::ApplicationController
      before_action :build_recruitment_cycle

      def index
        authorize Organisation
        @organisations = Organisation.all.sort_by(&:name)
        render jsonapi: @organisations, include: params[:include]
      end

    private

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.current_recruitment_cycle
      end
    end
  end
end
