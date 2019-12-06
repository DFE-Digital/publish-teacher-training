module API
  module V2
    class OrganisationsController < API::V2::ApplicationController
      def index
        authorize Organisation
        @organisations = Organisation.all
        if params_includes_provider?
          current_recruitment_cycle = RecruitmentCycle.current
          @organisations = @organisations.includes(:providers)
                             .where(provider: { recruitment_cycle_id: current_recruitment_cycle.id })
        end

        render jsonapi: @organisations, include: params[:include]
      end

    private

      def params_includes_provider?
        if params[:include].present?
          "providers".in?(params[:include])
        end
      end
    end
  end
end
