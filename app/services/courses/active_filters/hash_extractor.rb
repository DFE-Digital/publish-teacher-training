# frozen_string_literal: true

module Courses
  module ActiveFilters
    class HashExtractor
      SKIP_KEYS = %w[
        applications_open
        radius
        location
        formatted_address
        subject_code
        provider_code
        provider_name
      ].freeze

      DEFAULT_SKIP = {
        "minimum_degree_required" => "show_all_courses",
        "level" => "all",
        "order" => "course_name_ascending",
      }.freeze

      FILTER_ORDER = %i[
        provider_code
        subjects
        short_address
        engineers_teach_physics
        level
        send_courses
        funding
        study_types
        qualifications
        minimum_degree_required
        can_sponsor_visa
        interview_location
        start_date
        order
      ].freeze

      def initialize(attrs, subject_names: [], provider_name: nil)
        @attrs = attrs.to_h.transform_keys(&:to_s)
        @subject_names = subject_names
        @provider_name = provider_name
      end

      def call
        filters = []
        filters << provider_filter if @provider_name.present?
        filters.concat(subject_filters)
        filters.concat(location_filters)
        filters.concat(translatable_filters)
        sort_filters(filters).select { |f| f.formatted_value.present? }
      end

    private

      def provider_filter
        Courses::ActiveFilter.new(
          id: :provider_code,
          raw_value: @provider_name,
          value: @provider_name,
          remove_params: {},
        )
      end

      def subject_filters
        @subject_names.map do |name|
          Courses::ActiveFilter.new(
            id: :subjects,
            raw_value: name,
            value: name,
            remove_params: {},
          )
        end
      end

      def location_filters
        name = @attrs["location"] || @attrs["formatted_address"]
        return [] if name.blank?

        radius = @attrs["radius"]
        display = radius.present? ? "Within #{radius} miles of #{name}" : name

        [Courses::ActiveFilter.new(
          id: :short_address,
          raw_value: display,
          value: display,
          remove_params: {},
        )]
      end

      def translatable_filters
        @attrs.flat_map do |key, value|
          next [] if SKIP_KEYS.include?(key)
          next [] if value.blank?
          next [] if DEFAULT_SKIP[key] == value

          Array(value).map do |v|
            Courses::ActiveFilter.new(
              id: key.to_sym,
              raw_value: v,
              value: v,
              remove_params: {},
            )
          end
        end
      end

      def sort_filters(filters)
        filters.sort_by do |filter|
          idx = FILTER_ORDER.index(filter.id)
          idx || FILTER_ORDER.length
        end
      end
    end
  end
end
