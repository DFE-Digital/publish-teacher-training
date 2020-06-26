module API
  module V2
    class OrganisationsController < API::V2::ApplicationController
      def index
        authorize Organisation
        @organisations = Organisation.all
        if params_includes_provider?
          current_recruitment_cycle = RecruitmentCycle.current
          @organisations = @organisations.includes(:providers, :users, :nctl_organisations)
                             .where(provider: { recruitment_cycle_id: current_recruitment_cycle.id })

        end

        render jsonapi: paginate(@organisations.order(:name), per_page: per_page),
               include: params[:include],
               meta: { count: @organisations.count },
               fields: {
                 providers: %i[provider_code provider_name],
                 users: %i[email sign_in_user_id first_name last_name],
               }
      end

    private

      def params_includes_provider?
        if params[:include].present?
          "providers".in?(params[:include])
        end
      end

      def per_page
        params.dig(:page, :per_page) || 10
      end
    end
  end
end
