require "rails_helper"

RSpec.describe Courses::ActiveFiltersComponent, type: :component do
  subject(:result) { rendered.text.gsub(/\r?\n/, " ").squeeze(" ").strip }

  # The Find results page, whose URLs this component used to build itself.
  let(:path_builder) { ->(params) { Rails.application.routes.url_helpers.find_results_path(params) } }
  let(:clear_all_path) do
    Rails.application.routes.url_helpers.find_results_path(utm_source: "results", utm_medium: "clear_all_filters_top")
  end

  def rendered
    render_inline(described_class.new(active_filters:, search_params:, path_builder:, clear_all_path:))
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

  context "when a caller lists something other than find results" do
    let(:active_filters) do
      [Courses::ActiveFilter.new(id: :status, raw_value: "open", value: "Open", formatted_value: "Open", remove_params: { status: nil })]
    end
    let(:search_params) { { status: %w[open] } }
    let(:path_builder) { ->(params) { "/publish/organisations/ABC/2026/courses?#{params.compact.to_query}" } }
    let(:clear_all_path) { "/publish/organisations/ABC/2026/courses" }

    it "builds the remove link from the caller's path" do
      expect(rendered.css(".app-active-filters__remove-filter").first[:href]).to eq("/publish/organisations/ABC/2026/courses?")
    end

    it "uses the caller's clear all path" do
      expect(rendered.css(".app-c-filter-summary__clear-filters").first[:href]).to eq("/publish/organisations/ABC/2026/courses")
    end

    it "labels the chip with the filter's formatted value" do
      expect(result).to include("Open")
    end
  end

  context "when the caller names the clear all link differently" do
    let(:active_filters) do
      [Courses::ActiveFilter.new(id: :send_courses, raw_value: true, value: true, remove_params: { send_courses: nil })]
    end
    let(:search_params) { { send_courses: true } }

    it "uses that text" do
      component = described_class.new(active_filters:, search_params:, path_builder:, clear_all_path:, clear_all_text: "Clear all filters")

      expect(render_inline(component).css(".app-c-filter-summary__clear-filters").text).to eq("Clear all filters")
    end

    it "says Clear all by default" do
      expect(rendered.css(".app-c-filter-summary__clear-filters").text).to eq("Clear all")
    end
  end
end
