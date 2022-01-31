module PublishInterface
  module Providers
    class CoursesController < PublishInterfaceController
      def index
        authorize :provider, :index?

        courses_by_accrediting_provider
        self_accredited_courses
      end

    private

      def provider
        @provider ||= Provider
          .includes(courses: %i[sites site_statuses enrichments provider])
          .find_by!(recruitment_cycle: recruitment_cycle, provider_code: params[:provider_code])
      end

      def recruitment_cycle
        cycle_year = params[:recruitment_cycle_year] || params[:year] || Settings.current_recruitment_cycle_year

        @recruitment_cycle ||= RecruitmentCycle.find_by!(year: cycle_year)
      end

      def courses_by_accrediting_provider
        @courses_by_accrediting_provider ||= ::Courses::Fetch.by_accrediting_provider(provider)
      end

      def self_accredited_courses
        @self_accredited_courses ||= courses_by_accrediting_provider.delete(provider.provider_name)
      end
    end
  end
end
