# frozen_string_literal: true

module Publish
  # Presentation facade over Publish::Courses::Query for the publish course list
  # page. Chunks the pre-ordered query rows into accredited-provider groups.
  #
  # Filters are passed straight through to the query, so a group whose courses
  # are all filtered out simply does not appear.
  class CourseList
    include Enumerable

    # A group is self-accredited (rendered without a heading) when it has no
    # accredited provider name.
    Group = Data.define(:accredited_provider_name, :courses) do
      def self_accredited?
        accredited_provider_name.nil?
      end

      def heading
        accredited_provider_name
      end
    end

    # The course-information fields shown per course, in display order. Each maps
    # to the raw value that drives its displayed text, so uniformity is compared
    # on that value rather than the rendered label.
    FIELDS = {
      funding: ->(course) { course.funding },
      qualification: ->(course) { course.qualification },
      study_mode: ->(course) { course.study_mode },
      start_date: ->(course) { course.start_date.presence&.to_date },
    }.freeze

    # The value each filter group varies on, in panel order. A group whose value
    # is identical across the whole list offers no useful choice, so it is hidden.
    # Start date is compared by month because the filter groups by month; status
    # by the token the filter selects on rather than the rendered label.
    FILTER_FACETS = {
      status: ->(course) { Publish::Courses::StatusTag.token(course) },
      level: ->(course) { course.level },
      funding: FIELDS[:funding],
      qualification: FIELDS[:qualification],
      study_mode: FIELDS[:study_mode],
      start_date: ->(course) { course.start_date.presence&.to_date&.beginning_of_month },
    }.freeze

    # Asks whether any course survived the filters rather than whether any group
    # did, so a group that keeps its place with nothing in it is not a list.
    def any?
      groups.any? { |group| group.courses.any? }
    end

    def initialize(provider:, params: {})
      @provider = provider
      @params = params
    end

    # Course-information fields whose value varies across the provider's whole
    # course list. A field that is identical for every course carries no
    # information worth showing, so it is omitted from the column. This is a
    # property of the whole list, measured on the unfiltered set, so filtering
    # never adds or removes a column.
    def visible_course_information_fields
      @visible_course_information_fields ||=
        FIELDS.keys.select { |key| unfiltered_courses.map(&FIELDS.fetch(key)).uniq.size > 1 }
    end

    # The filter groups worth showing: those whose value varies across the whole
    # (unfiltered) list, plus any group with a filter already applied so an active
    # filter is never hidden from its panel. Measured on the unfiltered set so
    # filtering never removes a filter mid-use.
    def visible_filter_groups
      @visible_filter_groups ||= FILTER_FACETS.keys.select do |group|
        params.key?(group) || unfiltered_courses.map(&FILTER_FACETS.fetch(group)).uniq.size > 1
      end
    end

    def groups
      @groups ||= courses
        .chunk_while { |a, b| a[:group_name] == b[:group_name] }
        .map { |chunk| Group.new(accredited_provider_name: chunk.first[:group_name], courses: chunk.map(&:decorate)) }
    end

    def each(&)
      groups.each(&)
    end

  private

    attr_reader :provider, :params

    def courses
      @courses ||= Publish::Courses::Query.call(provider:, params:).to_a
    end

    # The whole list, ignoring filters. Reuses the already-run filtered rows when
    # nothing is filtered, so the common first load runs no extra query.
    def unfiltered_courses
      @unfiltered_courses ||= params.blank? ? courses : Publish::Courses::Query.call(provider:).to_a
    end
  end
end
