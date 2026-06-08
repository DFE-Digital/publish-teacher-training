# frozen_string_literal: true

module Publish
  module Courses
    # Renders one section of the publish course list: an optional accredited
    # provider heading followed by the group's table of courses. Self-accredited
    # groups are rendered without a heading.
    class GroupComponent < ApplicationComponent
      def initialize(group:, provider:, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @group = group
        @provider = provider
      end

      attr_reader :group, :provider

      def show_heading?
        !group.self_accredited?
      end

      delegate :heading, to: :group

      delegate :courses, to: :group
    end
  end
end
