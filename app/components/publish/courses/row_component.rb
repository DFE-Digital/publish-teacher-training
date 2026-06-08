# frozen_string_literal: true

module Publish
  module Courses
    # Renders a single course row in the publish course list table.
    class RowComponent < ApplicationComponent
      def initialize(course:, provider:, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @course = course
        @provider = provider
      end

      attr_reader :course, :provider

      delegate :name_and_code, to: :course

      def course_path
        helpers.publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          course.recruitment_cycle.year,
          course.course_code,
        )
      end

      def on_courses_index_page?
        helpers.current_page?(
          helpers.publish_provider_recruitment_cycle_courses_path(
            provider.provider_code,
            course.recruitment_cycle.year,
          ),
        )
      end

      def age_range
        return if course.age_range_in_years.blank?

        "Ages #{course.age_range}"
      end

      def recruitment_cycle_year
        course.recruitment_cycle.year
      end
    end
  end
end
