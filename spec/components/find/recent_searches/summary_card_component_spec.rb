# frozen_string_literal: true

require "rails_helper"

module Find
  module RecentSearches
    describe SummaryCardComponent, type: :component do
      it "includes utm_source=recent_searches in the search again path" do
        recent_search = create(
          :recent_search,
          subjects: %w[C1],
          search_attributes: { "level" => "secondary" },
        )

        component = described_class.new(recent_search:)

        render_inline(component)

        expect(page).to have_link("Search again", href: /utm_source=recent_searches/)
      end

      it "capitalises the first letter of the lower-cased shared title" do
        recent_search = create(:recent_search, subjects: %w[C1])
        component = described_class.new(recent_search:, subject_names_by_code: { "C1" => "Mathematics" })

        render_inline(component)

        expect(page).to have_text("Mathematics courses in England")
      end
    end
  end
end
