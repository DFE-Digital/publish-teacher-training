# frozen_string_literal: true

module Publish
  module Courses
    # Renders a table of courses (one accredited-provider group, or the flat
    # training-partners list) for the publish course list: the course name and age,
    # the course-information column (funding / qualification / study type / start
    # date) and the status tag. Rows are read-model rows from Publish::Courses::Query.
    class TableComponent < ApplicationComponent
      def initialize(courses:, provider:, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @courses = courses
        @provider = provider
      end

      attr_reader :courses, :provider

      def course_path(course)
        helpers.publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          course.recruitment_cycle.year,
          course.course_code,
        )
      end

      def on_courses_index_page?(course)
        helpers.current_page?(
          helpers.publish_provider_recruitment_cycle_courses_path(
            provider.provider_code,
            course.recruitment_cycle.year,
          ),
        )
      end

      def age_range(course)
        return if course.secondary_course?
        return if course.age_range_in_years.blank?

        "Ages #{course.age_range}"
      end

      def funding_label(course)
        I18n.t("publish.courses.course_table.funding.#{course.funding}")
      end

      def study_type_label(course)
        course.study_mode_description.capitalize
      end

      def start_date(course)
        return if course.start_date.blank?

        I18n.l(course.start_date.to_date, format: :short)
      end

      def recruitment_cycle_year(course)
        course.recruitment_cycle.year
      end
    end
  end
end
