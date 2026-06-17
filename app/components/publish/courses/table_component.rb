# frozen_string_literal: true

module Publish
  module Courses
    # Renders a table of courses (one accredited-provider group, or the flat
    # training-partners list) for the publish course list: the course name and age,
    # the course-information column (funding / qualification / study type / start
    # date) and the status tag. Rows are read-model rows from Publish::Courses::Query.
    class TableComponent < ApplicationComponent
      def initialize(courses:, provider:, course_information_fields: Publish::CourseList::FIELDS.keys, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @courses = courses
        @provider = provider
        @course_information_fields = course_information_fields
      end

      attr_reader :courses, :provider, :course_information_fields

      def show_field?(key)
        course_information_fields.include?(key)
      end

      def course_information_column?
        course_information_fields.any?
      end

      # Lines this row actually renders: a shown start-date field still produces
      # no line when this particular course has no start date, so the count is
      # decided per row rather than per column.
      def course_information_line_count(course)
        course_information_fields.count do |key|
          key == :start_date ? start_date(course).present? : true
        end
      end

      # A row is sparse when it shows at most one course-information line
      # (including the "column dropped entirely" case, where the count is 0).
      def sparse_row?(course)
        course_information_line_count(course) <= 1
      end

      def row_classes(course)
        classes = %w[govuk-table__row]
        classes << "app-table--courses__row--sparse" if sparse_row?(course)
        classes.join(" ")
      end

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
