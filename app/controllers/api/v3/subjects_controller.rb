module API
  module V3
    class SubjectsController < API::V3::ApplicationController
      def index
        subjects = Subject.active

        if params["sort"] == "subject_name"
          subjects = subjects.order(:subject_name)
        end

        render jsonapi: subjects, fields: fields_param, include: params[:include], class: CourseSerializersService.new.execute[:v3]
      end
    end
  end
end
