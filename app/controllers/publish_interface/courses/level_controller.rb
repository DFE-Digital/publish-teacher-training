module PublishInterface
  module Courses
    class LevelController < PublishInterfaceController
      def new
        authorize(provider, :index?)

        @course_levels_form = LevelsForm.new
      end

      def create
        authorize(provider, :index?) # TODO: include proper authorization

        @course_levels_form = LevelsForm.new(params: course_level_params)

        if @course_levels_form.stash_or_save
          # TODO: include the wizard to figure out the next step
          redirect_to(relevant_path)
        else
          render(:new)
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

      def course_level_params
        params.require(:publish_interface_courses_levels_form).permit(
          :level,
          :is_send,
        )
      end
    end
  end
end
