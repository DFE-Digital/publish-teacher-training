module PublishInterface
  module Courses
    class ConfirmationController < PublishInterfaceController
      include CourseBasicDetailConcern

      decorates_assigned :course

      def confirmation
        # TODO: fix authorization
        authorize(provider, :index?)
        recruitment_cycle
      end

    private

      def provider
        @provider ||= Provider
          .includes(courses: %i[sites site_statuses enrichments provider])
          .find_by!(recruitment_cycle: recruitment_cycle, provider_code: params[:provider_code])
      end

      def recruitment_cycle
        @recruitment_cycle ||= RecruitmentCycle.find_by(
          year: params[:recruitment_cycle_year],
        ) || RecruitmentCycle.current_recruitment_cycle
      end
    end
  end
end
