module API
  module V3
    class ApplicationController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :jsonapi_404

      before_action :check_disable_pagination

      def jsonapi_404
        render jsonapi: nil, status: :not_found
      end

    private

      def check_disable_pagination
        return unless params[:page]

        if params[:page][:per_page].to_i > Kaminari.config.default_per_page
          return if allowed_to_disable_pagination?

          params[:page][:per_page] = Kaminari.config.default_per_page
        end
      end

      # Override if you want to allow an endpoint to disable pagaination
      # e.g. by checking params
      def allowed_to_disable_pagination?
        false
      end

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
