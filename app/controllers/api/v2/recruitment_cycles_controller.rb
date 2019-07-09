module API
  module V2
    class RecruitmentCyclesController < ApplicationController
      before_action :build_recruitment_cycle

      def show
        authorize @recruitment_cycle, :show?

        render jsonapi: @recruitment_cycle, include: params[:include]
      end

    private

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.find_by(year: params[:year])
      end
    end
  end
end
