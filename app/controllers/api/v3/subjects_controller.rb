module API
  module V3
    class SubjectsController < API::V3::ApplicationController
      def index
        render jsonapi: Subject.active, fields: fields_param, include: params[:include], class: CourseSerializersService.new.execute[:v3]
      end
    end
  end
end
