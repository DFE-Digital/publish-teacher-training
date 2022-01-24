module PublishInterface
  module Courses
    class LevelController < PublishInterfaceController
      # include CourseBasicDetailConcern

      def new
        authorize(provider, :show?)
      end

    private

      def provider
        @provider ||= Provider.find_by!(recruitment_cycle: recruitment_cycle, provider_code: params[:provider_code])
      end

      def recruitment_cycle
        cycle_year = params[:recruitment_cycle_year] || params[:year] || Settings.current_recruitment_cycle_year

        @recruitment_cycle ||= RecruitmentCycle.find_by!(year: cycle_year)
      end

      def error_keys
        [:level]
      end

      def current_step
        :level
      end
    end
  end
end
