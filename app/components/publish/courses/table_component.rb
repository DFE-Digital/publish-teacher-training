# frozen_string_literal: true

module Publish
  module Courses
    # Renders a table of courses (one accredited-provider group, or the flat
    # training-partners list) for the publish course list: the course name and age,
    # the course-information column (funding / qualification / study type / start
    # date) and the status tag. Rows are read-model rows from Publish::Courses::Query.
    class TableComponent < ApplicationComponent
      def initialize(courses:, provider:, course_information_fields: Publish::CourseList::FIELDS.keys, view_course_column: false, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @courses = courses
        @provider = provider
        @course_information_fields = course_information_fields
        @view_course_column = view_course_column
        @live_on_find = {}
      end

      attr_reader :courses, :provider, :course_information_fields

      def show_field?(key)
        course_information_fields.include?(key)
      end

      def course_information_column?
        course_information_fields.any?
      end

      # Asked for by the training partner course list, where the course name is
      # not a link and Find is the only way to see the course. Dropped when
      # nothing in the list is live, rather than heading a column of empty cells.
      def view_course_column?
        @view_course_column && courses.any? { |course| live_on_find?(course) }
      end

      # Reads the content status from the row's computed column rather than
      # Course#content_status, which would run the enrichment service per row.
      def live_on_find?(course)
        @live_on_find.fetch(course.id) do
          @live_on_find[course.id] = ::Courses::PublishRules::LiveOnFind.applies?(
            course,
            content_status: course.read_attribute(:content_status),
          )
        end
      end

      def table_classes
        table = %w[govuk-table app-table--courses]
        table << "app-table--courses--no-information" unless course_information_column?
        table << "app-table--courses--view-course" if view_course_column?
        table.join(" ")
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

      # The path is built from this table's provider, which Publish looks up
      # with provider.courses.find_by!(course_code:). Linking when that
      # provider does not own the course 404s, or opens a different course
      # that happens to share the code — as on the training-partners list,
      # where @provider is the accredited provider.
      def link_to_course?(course)
        course.provider_id == provider.id
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
