# frozen_string_literal: true

module Publish
  # Presentation facade over Publish::Courses::Query for the publish course list
  # page. Chunks the pre-ordered query rows into accredited-provider groups.
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

    delegate :any?, to: :groups

    def initialize(provider:)
      @provider = provider
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

    attr_reader :provider

    def courses
      @courses ||= Publish::Courses::Query.call(provider:).to_a
    end
  end
end
