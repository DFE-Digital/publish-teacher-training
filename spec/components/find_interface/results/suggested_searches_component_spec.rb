require "rails_helper"

module FindInterface
  describe Results::SuggestedSearchesComponent, type: :component do
    it "is not rendered when `suggested_search_visible?` is false" do
      results_view = instance_double(Find::ResultsView, suggested_search_visible?: false)
      component = render_inline(described_class.new(results: results_view))

      expect(component.text).to eq("")
    end

    it "is rendered when `suggested_search_visible?` is false with the given links" do
      results_view = instance_double(
        Find::ResultsView,
        suggested_search_visible?: true,
        suggested_search_links: [
          Find::SuggestedSearchLink.new(
            radius: 25,
            count: 53,
            parameters: {},
            explicit_salary_filter: false,
          ),
          Find::SuggestedSearchLink.new(
            radius: 50,
            count: 146,
            parameters: {},
            explicit_salary_filter: false,
          ),
        ],
      )
      component = render_inline(described_class.new(results: results_view))

      expect(component.text).to include("Suggested searches")
      expect(component.text).to include("53 courses within 25 miles")
      expect(component.text).to include("146 courses within 50 miles")
    end
  end
end
