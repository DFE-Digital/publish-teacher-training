module Publish
  module Providers
    class CoursesController < PublishController
      decorates_assigned :course

      def index
        authorize :provider, :index?

        courses_by_accrediting_provider
        self_accredited_courses
      end

      def show
        fetch_course

        authorize @course

        @errors = flash[:error_summary]
        flash.delete(:error_summary)
      end

      def details
        fetch_course

        authorize @course
      end

    private

      def fetch_course
        @course = provider.courses.find_by!(course_code: params[:code])
      end

      def provider
        @provider ||= Provider
          .includes(courses: %i[sites site_statuses enrichments provider])
          .find_by!(recruitment_cycle: recruitment_cycle, provider_code: params[:provider_code])
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
