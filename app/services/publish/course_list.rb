# frozen_string_literal: true

module Publish
  # Presentation facade over ProviderCoursesQuery for the publish course list
  # page. Exposes the ordered course groups as an enumerable for the view.
  class CourseList
    include Enumerable

    delegate :groups, to: :query
    delegate :any?, to: :groups

    def initialize(provider:)
      @query = ProviderCoursesQuery.new(provider:)
    end

    def each(&)
      groups.each(&)
    end

  private

    attr_reader :query
  end
end
