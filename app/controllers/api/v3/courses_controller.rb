module API
  module V3
    class CoursesController < API::V3::ApplicationController
      before_action :build_recruitment_cycle
      before_action :build_provider
      before_action :build_course

      def show
        if @course.is_published?
          render jsonapi: @course, fields: fields_param
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
    end
  end
end
