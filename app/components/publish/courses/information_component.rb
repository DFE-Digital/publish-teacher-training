# frozen_string_literal: true

module Publish
  module Courses
    # Renders the "Course information" column for a course in the publish course
    # list: funding type, qualification, study type and start date, each on its
    # own line.
    class InformationComponent < ApplicationComponent
      def initialize(course:, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @course = course
      end

      attr_reader :course

      def funding_label
        I18n.t("publish.courses.information_component.funding.#{course.funding}")
      end

      def qualification_label
        course.qualifications_summary
      end

      def study_type_label
        course.study_mode_description.capitalize
      end

      def start_date
        return if course.start_date.blank?

        I18n.l(course.start_date.to_date, format: :short)
      end
    end
  end
end
