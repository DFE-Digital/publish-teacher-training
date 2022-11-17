# frozen_string_literal: true

module FeatureHelpers
  module PageWithQuery
    def expect_page_to_be_displayed_with_query(page:, expected_query_params:)
      current_query_string = current_url.match('\?(.*)$').captures.first
      url_params = { course: expected_query_params }

      expect(page).to be_displayed
      query = Rack::Utils.parse_nested_query(current_query_string).deep_symbolize_keys
      expect(query).to match(url_params)
    end
  end
end
