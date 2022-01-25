module PublishInterface
  module Courses
    class LevelController < PublishInterfaceController
      def new
        authorize(provider, :index?)

        @course = Course.new
        @course_levels_form = LevelsForm.new(@course)
      end

      def create
        if @course_levels_form.stash_or_save!
          redirect_to(relevant_path)
        else
          render(:edit)
        end
      end

    private

      def provider
        @provider ||= Provider.find_by!(recruitment_cycle: recruitment_cycle, provider_code: params[:provider_code])
      end

      def recruitment_cycle
        cycle_year = params[:recruitment_cycle_year] || params[:year] || Settings.current_recruitment_cycle_year

        @recruitment_cycle ||= RecruitmentCycle.find_by!(year: cycle_year)
      end
    end
  end
end
