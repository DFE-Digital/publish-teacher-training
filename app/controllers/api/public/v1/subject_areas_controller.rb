# frozen_string_literal: true

module API
  module Public
    module V1
      class SubjectAreasController < ApplicationController
        def index
          render(
            jsonapi: SubjectArea.active.includes(subjects: [:financial_incentive]),
            include: params[:include],
            class: API::Public::V1::SerializerService.call,
          )
        end
      end
    end
  end
end
