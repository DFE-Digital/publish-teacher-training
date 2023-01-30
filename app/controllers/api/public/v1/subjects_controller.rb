# frozen_string_literal: true

module API
  module Public
    module V1
      class SubjectsController < API::Public::V1::ApplicationController
        def index
          subjects = Subject.active.includes(:financial_incentive)

          subjects = subjects.order(:subject_name) if params['sort'] == 'name'
          render jsonapi: subjects,
                 class: API::Public::V1::SerializerService.call,
                 include: params[:include],
                 fields:
        end

        def fields
          { subjects: subject_fields } if subject_fields.present?
        end

        def subject_fields
          params.dig(:fields, :subjects)&.split(',')
        end
      end
    end
  end
end
