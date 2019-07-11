module API
  module V2
    class RecruitmentCyclesController < ApplicationController
      before_action :build_recruitment_cycle

      def index
        authorize RecruitmentCycle

        @recruitment_cycles =
          if params.key? :provider_code
            policy_scope(Provider)
              .where(provider_code: params[:provider_code])
              .includes(:recruitment_cycle)
              .map(&:recruitment_cycle)
          else
            policy_scope(RecruitmentCycle).all
          end

        render jsonapi: @recruitment_cycles, include: params[:include]
      end

      def show
        authorize @recruitment_cycle, :show?

        render jsonapi: @recruitment_cycle, include: params[:include]
      end

    private

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle
                               .includes(providers: [:enrichments, :latest_published_enrichment])
                               .find_by(year: params[:year])
      end
    end
  end
end
