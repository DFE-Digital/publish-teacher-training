module API
  module V3
    class CoursesController < API::V3::ApplicationController
      before_action :build_recruitment_cycle
      before_action :build_provider
      before_action :build_courses

      def index
        course_search = CourseSearchService.call(filter: params[:filter], sort: params[:sort], course_scope: @courses)

        render jsonapi: paginate(course_search),
          fields: fields_param,
          include: params[:include],
          meta: { count: course_search.count("course.id") },
          class: CourseSerializersServiceV3.new.execute
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

      def max_per_page
        if fields_for_sitemap?
          20_000
        else
          super
        end
      end

      def fields_for_sitemap?
        if (courses = params.dig(:fields, :courses))
          (courses.split(",") & %w[course_code provider_code changed_at]).size == 3
        end
      end

      def build_courses
        @courses = if @provider.present?
                     @provider.courses.includes(:provider).findable
                   else
                     @recruitment_cycle.courses.includes(:provider).findable
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
