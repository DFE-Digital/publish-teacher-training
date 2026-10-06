# frozen_string_literal: true

module Publish
  module Courses
    # The filter values present on the course list rows. Every group is read
    # from those rows, so the panel does not offer an option no course has.
    #
    # Status is the token the provider sees (Open, Closed, Scheduled), not the
    # raw enrichment status. A course offered full time or part time counts for
    # both study mode options, and a PGCE or PGDE with QTS counts as that
    # qualification option. Start date is the month the list displays, in the
    # application time zone: a course starting 2026-09-01 00:30 is stored as
    # 2026-08-31 23:30 UTC, but the list and the query treat it as September.
    module AvailableFilterOptions
      def self.for(courses)
        {
          status: courses.map { |course| StatusTag.token(course).to_s },
          level: courses.map(&:level),
          funding: courses.map(&:funding),
          qualification: courses.flat_map { |course| qualification_options(course.qualification) },
          study_mode: courses.flat_map { |course| study_mode_options(course.study_mode) },
          start_date: courses.filter_map { |course| start_month(course) }.uniq.sort,
        }.transform_values { |values| values.compact.uniq }
      end

      def self.qualification_options(qualification)
        Query::QUALIFICATION_OPTIONS.filter_map do |option, keys|
          option if keys.include?(qualification.to_s.to_sym)
        end
      end

      def self.study_mode_options(study_mode)
        Query::STUDY_MODE_OPTIONS.filter_map do |option, keys|
          option if keys.include?(study_mode.to_s.to_sym)
        end
      end

      def self.start_month(course)
        return if course.start_date.blank?

        course.start_date.in_time_zone.to_date.beginning_of_month
      end

      private_class_method :qualification_options, :study_mode_options, :start_month
    end
  end
end
