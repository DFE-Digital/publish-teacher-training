# frozen_string_literal: true

module Publish
  module Schools
    class SearchResultTitlePreview < ViewComponent::Preview
      def with_many_results = render_component(10_000)

      def with_few_results = render_component(10)

      def with_1_result = render_component(1)

      def with_no_results = render_component(0)

      private

      def query = 'test'
      def return_path = '/test'
      def results_limit = 15

      def render_component(results_count)
        render(
          Schools::SearchResultTitleComponent.new(
            query:,
            results_limit:,
            results_count:,
            return_path:
          )
        )
      end
    end
  end
end
