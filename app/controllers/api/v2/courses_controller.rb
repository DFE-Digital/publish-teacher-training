module API
  module V2
    class CoursesController < API::V2::ApplicationController
      before_action :build_provider
      before_action :build_course, except: :index

      def index
        authorize @provider, :can_list_courses?
        authorize Course

        render jsonapi: @provider.courses, include: params[:include]
      end

      def show
        render jsonapi: @course, include: params[:include]
      end

      def sync_with_search_and_compare
        response = ManageCoursesAPI::Request.sync_course_with_search_and_compare(
          @current_user.email,
          @provider.provider_code,
          @course.course_code
        )

        head response ? :ok : :internal_server_error
      end

      def publish
        if @provider.opted_in
          update_new_to_running
          update_published_if_running
        end
        publish_enrichment

        response = ManageCoursesAPI::Request.sync_course_with_search_and_compare(
          @current_user.email,
          @provider.provider_code,
          @course.course_code
        )

        head response ? :ok : :internal_server_error
      end

      def update_new_to_running
        @course.site_statuses.where(status: 'new_status').update_all(status: 'running')
      end

      def update_published_if_running
        @course.site_statuses.where(status: 'running', publish: 'unpublished').update_all(publish: 'published')
      end

      def publish_enrichment
        @course.enrichments.where(status: 'draft').update_all(status: 'published')
      end

    private

      def build_provider
        @provider = Provider.find_by!(provider_code: params[:provider_code].upcase)
      end

      def build_course
        @course = @provider.courses.find_by!(course_code: params[:code].upcase)
        authorize @course
      end
    end
  end
end
