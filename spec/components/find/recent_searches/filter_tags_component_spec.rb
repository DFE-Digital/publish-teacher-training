# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::RecentSearches::FilterTagsComponent, type: :component do
  describe "HTML escaping of user-controlled input" do
    context "when location contains HTML injection" do
      let(:active_filters) do
        Courses::ActiveFilters::HashExtractor.new(
          { "location" => '<script>alert("xss")</script>', "radius" => "10" },
          subject_names: [],
          provider_name: nil,
        ).call
      end

      it "escapes HTML in filter tag values" do
        rendered = render_inline(described_class.new(active_filters:))

        expect(rendered.to_html).not_to include("<script>")
        expect(rendered.text).to include('alert("xss")')
      end
    end

    context "when provider_name contains HTML injection" do
      let(:active_filters) do
        Courses::ActiveFilters::HashExtractor.new(
          {},
          subject_names: [],
          provider_name: '<img src=x onerror="alert(1)">',
        ).call
      end

      it "escapes HTML in filter tag values" do
        rendered = render_inline(described_class.new(active_filters:))

        expect(rendered.to_html).not_to include("<img src=x")
        expect(rendered.text).to include('onerror="alert(1)"')
      end
    end

    context "when formatted_address contains HTML injection" do
      let(:active_filters) do
        Courses::ActiveFilters::HashExtractor.new(
          { "formatted_address" => '<div onmouseover="alert(1)">hover me</div>' },
          subject_names: [],
          provider_name: nil,
        ).call
      end

      it "escapes HTML in filter tag values" do
        rendered = render_inline(described_class.new(active_filters:))

        expect(rendered.to_html).not_to include("<div onmouseover")
        expect(rendered.text).to include("hover me")
      end
    end
  end
end
