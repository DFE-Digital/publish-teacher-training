# frozen_string_literal: true

module Publish
  module Schools
    class SearchResultTitleComponent < ViewComponent::Base
      def initialize(query:, results_limit:, results_count:, return_path:)
        @query = query
        @results_limit = results_limit
        @results_count = results_count
        @return_path = return_path
        super
      end

      def title
        [
          count_text,
          found_text,
          query_text
        ].compact.join(' ')
      end

      def results_text
        return many_results_text if results_count > results_limit
        return "#{change_your_search_link}.".html_safe if results_count.zero?

        "#{change_your_search_link} if the school you’re looking for is not listed.".html_safe
      end

      private

      attr_reader :query, :results_limit, :results_count, :return_path

      def count_text
        return results_count if results_count >= 1

        'No'
      end

      def found_text
        return 'result found' if results_count == 1

        'results found'
      end

      def query_text
        return "for ‘#{query}’" if query.present?

        'for your search'
      end

      def many_results_text
        t('.many_results_html', link: govuk_link_to('Try narrowing down your search', return_path))
      end

      def change_your_search_link
        govuk_link_to('Change your search', return_path)
      end
    end
  end
end
