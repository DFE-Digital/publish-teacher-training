# frozen_string_literal: true

module API
  module V3
    class SubjectAreasController < API::V3::ApplicationController
      def index
        render jsonapi: SubjectArea.active.includes(subjects: [:financial_incentive]), fields: fields_param, include: params[:include], class: CourseSerializersService.new.execute
      end
    end
  end
end
