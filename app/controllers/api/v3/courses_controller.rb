module API
  module V3
    class CoursesController < API::V3::ApplicationController
      before_action :build_recruitment_cycle
      before_action :build_provider
      before_action :build_courses

      def index
        course_search = CourseSearchService.call(filter: params[:filter],
                                                 sort: params[:sort],
                                                 course_scope: @courses)

        results = if disable_pagination?
                    course_search
                  else
                    paginate(course_search)
                  end

        render jsonapi: results,
          fields: fields_param,
          include: params[:include],
          meta: { count: results.count },
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

      def disable_pagination?
        if params[:fields] && params[:fields][:courses]
          (params[:fields][:courses].split(",") & fields_required_to_disable_pagination).size == 3
        end
      end

      def fields_required_to_disable_pagination
        %w[course_code provider_code changed_at]
      end

      def build_courses
        @courses = if @provider.present?
                     @provider.courses.includes(:provider)
                   else
                     @recruitment_cycle.courses.includes(:provider)
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
