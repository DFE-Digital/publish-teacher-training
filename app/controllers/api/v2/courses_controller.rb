module API
  module V2
    class CoursesController < API::V2::ApplicationController
      def index
        provider = Provider.find_by!(provider_code: params[:provider_code])
        authorize provider, :can_list_courses?
        authorize Course

        render jsonapi: provider.courses
      end

      def show
        course = Course.find_by!(course_code: params[:code])
        authorize course

        render jsonapi: course, include: [site_statuses: [:site]]
      end
    end
  end
end
