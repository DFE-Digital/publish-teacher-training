module API
  module V3
    class ApplicationController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :jsonapi_404

      def jsonapi_404
        render jsonapi: nil, status: :not_found
      end

    private

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.find_by(
          year: params[:recruitment_cycle_year],
        ) || RecruitmentCycle.current_recruitment_cycle
      end

      def fields_param
        params.fetch(:fields, {})
          .permit(:subject_areas, :courses, :providers)
          .to_h
          .map { |k, v| [k, v.split(",").map(&:to_sym)] }
      end
    end
  end
end
