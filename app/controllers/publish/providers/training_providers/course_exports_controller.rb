# frozen_string_literal: true

module Publish
  module Providers
    module TrainingProviders
      class CourseExportsController < ApplicationController
        def index
          authorize(provider, :can_list_training_providers?)

          respond_to do |format|
            format.csv do
              send_data(data_export.data, filename: data_export.filename, disposition: :attachment)
            end
          end
        end

        private

        def courses
          @courses ||= provider.current_accredited_courses
        end

        def data_export
          @data_export ||= Exports::AccreditedCourseList.new(courses:)
        end
      end
    end
  end
end
