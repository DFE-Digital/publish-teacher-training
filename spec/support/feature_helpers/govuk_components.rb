# frozen_string_literal: true

module FeatureHelpers
  module GovukComponents
    def within_summary_row(row_description, &block)
      within(page.all(".govuk-summary-list__row").find { |row| row.has_text?(row_description) }) do
        block.call
      end
    end
  end
end
