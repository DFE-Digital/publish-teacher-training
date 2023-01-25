module API
  module V3
    class SubjectsController < API::V3::ApplicationController
      def index
        subjects = Subject.active

        subjects = subjects.order(:subject_name) if params["sort"] == "subject_name"

        render jsonapi: subjects, fields: fields_param, include: params[:include], class: CourseSerializersService.new.execute
      end
    end
  end
end
