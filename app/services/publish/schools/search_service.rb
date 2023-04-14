# frozen_string_literal: true

module Publish
  module Schools
    class SearchService
      include ServicePattern

      DEFAULT_LIMIT = 15

      Result = Struct.new(:schools, :limit, keyword_init: true)

      def initialize(query: nil, limit: DEFAULT_LIMIT)
        @query = StripPunctuationService.call(string: query)
        @limit = limit
      end

      def call
        Result.new(schools: specified_schools, limit:)
      end

      private

      attr_reader :query, :limit

      def specified_schools
        schools = GiasSchool.open
        schools = schools.search(query) if query
        schools = schools.limit(limit) if limit
        schools.reorder(:name)
      end
    end
  end
end
