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

    delegate :any?, to: :groups

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
