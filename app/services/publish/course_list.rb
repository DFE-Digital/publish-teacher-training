# frozen_string_literal: true

module Publish
  # Builds the ordered list of course groups shown on the publish course list
  # page. Replaces +Courses::Fetch.by_accrediting_provider+.
  #
  # A provider's courses are grouped by their accredited (ratifying) provider.
  # Courses with no accredited provider (or whose accredited provider is the
  # provider itself) form a single "self-accredited" group, which is always
  # ordered first and rendered without a heading. The remaining groups follow,
  # ordered case-insensitively by the accredited provider name.
  class CourseList
    include Enumerable

    delegate :any?, to: :groups

    def initialize(provider:)
      @provider = provider
    end

    def groups
      @groups ||= build_groups
    end

    def each(&)
      groups.each(&)
    end

  private

    attr_reader :provider

    def build_groups
      grouped = provider.courses.group_by { |course| group_name_for(course) }

      groups = grouped.map do |group_name, courses|
        CourseGroup.new(
          training_provider: provider,
          accredited_provider: accredited_provider_for(group_name, courses),
          courses:,
        )
      end

      self_group = groups.find(&:self_accredited?)
      other_groups = groups.reject(&:self_accredited?).sort_by { |group| group.heading.downcase }

      [self_group, *other_groups].compact
    end

    # Preserves the existing behaviour of grouping by provider name: courses with
    # no accredited provider fall into the provider's own (self-accredited)
    # bucket, and distinct accredited providers sharing a name are merged.
    def group_name_for(course)
      accrediting_provider(course)&.provider_name || provider.provider_name
    end

    def accredited_provider_for(group_name, courses)
      return nil if group_name == provider.provider_name

      courses.map { |course| accrediting_provider(course) }.compact.first
    end

    # The accrediting_provider association is recruitment-cycle scoped via a
    # lambda; guard the read narrowly so a malformed record is treated as
    # self-accredited rather than breaking the whole page.
    def accrediting_provider(course)
      course.accrediting_provider
    rescue StandardError
      nil
    end
  end
end
