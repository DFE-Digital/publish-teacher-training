module API
  module V2
    class CoursesController < API::V2::ApplicationController
      before_action :build_provider

      def index
        authorize @provider, :can_list_courses?
        authorize Course

        render jsonapi: @provider.courses
      end

      def show
        course = authorize Course.where(provider: @provider).find_by!(course_code: params[:code].upcase)
        render jsonapi: course, include: [site_statuses: [:site]]
      end

    private

      def build_provider
        @provider = Provider.find_by!(provider_code: params[:provider_code].upcase)
      end
    end
  end
end
