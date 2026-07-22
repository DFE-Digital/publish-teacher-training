require "rails_helper"

RSpec.describe Find::Courses::ActiveFilters::View, type: :component do
  subject(:result) do
    render_inline(
      described_class.new(active_filters:, search_params:),
    ).text.gsub(/\r?\n/, " ").squeeze(" ").strip
  end

  def rendered
    render_inline(described_class.new(active_filters:, search_params:))
  end

  context "when there are active filters" do
    let(:active_filters) do
      [
        Courses::ActiveFilter.new(
          id: :send_courses,
          raw_value: true,
          value: true,
          remove_params: { send_courses: nil },
        ),
      ]
    end
    let(:search_params) { { send_courses: true } }

    it "renders the correct content" do
      expect(result).to include("Courses with a SEND specialism")
    end

    it "links back to the results page with the filter dropped" do
      expect(rendered.css(".app-active-filters__remove-filter").first[:href]).to eq("/results")
    end
  end

  context "when other filters remain after removing one" do
    let(:active_filters) do
      [
        Courses::ActiveFilter.new(
          id: :funding,
          raw_value: "fee",
          value: "fee",
          remove_params: { funding: %w[salary] },
        ),
      ]
    end
    let(:search_params) { { funding: %w[fee salary], study_types: %w[full_time] } }

    it "keeps the remaining search params in the link" do
      expect(rendered.css(".app-active-filters__remove-filter").first[:href])
        .to eq("/results?funding%5B%5D=salary&study_types%5B%5D=full_time")
    end
  end

  context "when the clear all link is shown" do
    let(:active_filters) do
      [Courses::ActiveFilter.new(id: :send_courses, raw_value: true, value: true, remove_params: { send_courses: nil })]
    end
    let(:search_params) { { send_courses: true } }

    it "carries the tracking params identifying it as the top link" do
      expect(rendered.css(".app-c-filter-summary__clear-filters").first[:href])
        .to eq("/results?utm_medium=clear_all_filters_top&utm_source=results")
    end
  end

  context "when there are no active filters" do
    let(:active_filters) { [] }
    let(:search_params) {}

    it "renders the correct content" do
      expect(result).to eq("")
    end
  end
end
