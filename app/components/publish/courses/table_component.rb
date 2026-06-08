# frozen_string_literal: true

module Publish
  module Courses
    # Renders the table of courses for a single accredited-provider group.
    class TableComponent < ApplicationComponent
      def initialize(courses:, provider:, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @courses = courses
        @provider = provider
      end

      attr_reader :courses, :provider
    end
  end
end
