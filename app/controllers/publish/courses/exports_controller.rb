# frozen_string_literal: true

module Publish
  module Courses
    class ExportsController < ApplicationController
      def course_information
        send_csv(::Exports::CourseInformationList.new(provider:))
      end

      def schools
        send_csv(::Exports::CourseSchoolsList.new(provider:))
      end

    private

      def send_csv(export)
        authorize :provider, :index?

        respond_to do |format|
          format.csv { send_data(export.data, filename: export.filename, disposition: :attachment) }
        end
      end
    end
  end
end
