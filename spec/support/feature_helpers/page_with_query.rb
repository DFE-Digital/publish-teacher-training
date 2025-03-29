# frozen_string_literal: true

module FeatureHelpers
  module PageWithQuery
    def expect_page_to_be_displayed_with_query(page:, expected_query_params:)
      expect_query_params(expected_query_params)
      expect(page).to be_displayed
    end

    def expect_path_and_params(expected_path:, expected_query_params:)
      expect_query_params(expected_query_params)
      expect(page).to have_current_path(expected_path, ignore_query: true)
    end

    def expect_query_params(query_params)
      current_query_string = current_url.match('\?(.*)$').captures.first
      url_params = { course: query_params }
      query = Rack::Utils.parse_nested_query(current_query_string).deep_symbolize_keys
      expect(query).to match(url_params)
    end
  end
end
