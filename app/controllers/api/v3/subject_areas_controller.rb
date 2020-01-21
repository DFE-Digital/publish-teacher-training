module API
  module V3
    class SubjectAreasController < API::V3::ApplicationController
      def index
        render jsonapi: SubjectArea.active, fields: fields_param, include: params[:include], class: CourseSerializersService.new.execute[:v3]
      end
    end
  end
end
