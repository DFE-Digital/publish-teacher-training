# frozen_string_literal: true

module Support
  module Courses
    class ExportsController < ApplicationController
      def full_course_information
        export = ::Exports::FullCourseInformationList.new(provider:)

        respond_to do |format|
          format.csv { send_data(export.data, filename: export.filename, disposition: :attachment) }
        end
      end

    private

      def provider
        @provider ||= recruitment_cycle.providers.find(params[:provider_id])
      end
    end
  end
end
