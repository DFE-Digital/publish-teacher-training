module API
  module V3
    class CoursesController < API::V3::ApplicationController
      before_action :build_recruitment_cycle
      before_action :build_provider
      before_action :build_courses

      def index
        course_search = CourseSearchService.call(filter: params[:filter], sort: params[:sort], course_scope: @courses)

        render jsonapi: paginate(course_search), fields: fields_param, include: params[:include], meta: { count: course_search.count }, class: CourseSerializersService.new.execute
      end

      def show
        @course = @courses.find_by!(course_code: params[:code].upcase)

        if @course.is_published?
          # https://github.com/jsonapi-rb/jsonapi-rails/issues/113
          render jsonapi: @course, fields: fields_param, include: params[:include], class: CourseSerializersServiceV3.new.execute
        else
          raise ActiveRecord::RecordNotFound
        end
      end

    private

      def build_courses
        @courses = if @provider.present?
                     @provider.courses
                   else
                     @recruitment_cycle.courses
                   end
      end

      def build_provider
        if params[:provider_code].present?
          @provider = @recruitment_cycle.providers.find_by!(
            provider_code: params[:provider_code].upcase,
          )
        end
      end
    end
  end
end
