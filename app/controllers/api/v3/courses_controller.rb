module API
  module V3
    class CoursesController < API::V3::ApplicationController
      before_action :build_recruitment_cycle
      before_action :build_provider

      def index
        @courses = @provider.courses
        render jsonapi: @courses, include: params[:include]
      end

      def show
        @course = @provider.courses.find_by!(course_code: params[:code].upcase)

        if @course.is_published?
          render jsonapi: @course, fields: fields_param, include: params[:include]
        else
          raise ActiveRecord::RecordNotFound
        end
      end

      def fields_param
        params.fetch(:fields, {})
          .permit(:courses)
          .to_h
          .map { |k, v| [k, v.split(",").map(&:to_sym)] }
      end

    private

      def build_provider
        @provider = @recruitment_cycle.providers.find_by!(
          provider_code: params[:provider_code].upcase,
        )
      end
    end
  end
end
