# frozen_string_literal: true

module Publish
  module Courses
    # Renders the full publish course list: one group section per accredited
    # provider, in the order given by the course list.
    class ListComponent < ApplicationComponent
      def initialize(course_list:, provider:, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @course_list = course_list
        @provider = provider
      end

      attr_reader :course_list, :provider
    end
  end
end
