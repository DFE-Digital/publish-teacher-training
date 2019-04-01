module API
  module V2
    class CoursesController < API::V2::ApplicationController
      before_action :build_provider
      before_action :build_course, except: :index

      def index
        authorize @provider, :can_list_courses?
        authorize Course

        render jsonapi: @provider.courses
      end

      def show
        render jsonapi: @course, include: [site_statuses: [:site]]
      end

      def sync_with_search_and_compare
        response = ManageCoursesAPI::Request.sync_course_with_search_and_compare(
          @current_user.email,
          @provider.provider_code,
          @course.course_code
        )

        head response ? :ok : :internal_server_error
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
