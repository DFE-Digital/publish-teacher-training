# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Schools::SearchPanelComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(schools:)) }

  let(:schools) { [site] }
  let(:site) do
    build_stubbed(
      :site,
      id: 12,
      location_name: "Belvidere School",
      town: "Shrewsbury",
      postcode: "SY2 5RJ",
      urn: "123456",
    )
  end

  def option_for(site)
    rendered.css("option[value='#{site.id}']").first
  end

  def synonyms_for(site)
    option_for(site)["data-synonyms"].split("|")
  end

  describe "the school options" do
    it "labels each option with the school name" do
      expect(option_for(site).text).to eq("Belvidere School")
    end

    it "makes the URN searchable" do
      expect(synonyms_for(site)).to include("123456")
    end

    it "makes the postcode searchable with and without its space" do
      expect(synonyms_for(site)).to include("SY2 5RJ", "SY25RJ")
    end

    it "does not make the town searchable" do
      expect(synonyms_for(site)).not_to include("Shrewsbury")
    end

    it "shows the town and postcode as context in the dropdown" do
      expect(option_for(site)["data-append"]).to eq("(Shrewsbury, SY2 5RJ)")
    end

    it "renders a blank first option for the enhanced select" do
      expect(rendered.css("option").first.text).to be_blank
    end

    context "when the postcode has no space" do
      let(:site) { build_stubbed(:site, id: 12, postcode: "SY25RJ", urn: "123456") }

      it "does not repeat the postcode" do
        expect(synonyms_for(site).count("SY25RJ")).to eq(1)
      end
    end

    context "when the school has no URN or postcode" do
      let(:site) { build_stubbed(:site, :main_site, id: 12, postcode: nil) }

      it "renders the option without blank synonyms" do
        expect(synonyms_for(site)).to be_empty
      end
    end

    context "when the checkboxes are keyed by something other than the id" do
      subject(:rendered) { render_inline(described_class.new(schools:, value: :uuid)) }

      it "keys the options by that attribute instead" do
        expect(rendered.at_css("option[value='#{site.uuid}']").text).to eq("Belvidere School")
      end
    end
  end

  describe "the panel" do
    it "is hidden until the Stimulus controller reveals it" do
      expect(rendered.at_css(".app-school-search").attributes).to have_key("hidden")
    end

    it "gives the select no name, so it is never submitted with the surrounding form" do
      expect(rendered.css("select").first.attributes).not_to have_key("name")
    end

    it "renders both actions as buttons rather than submits" do
      expect(rendered.css("button").map { |button| button["type"] }).to all(eq("button"))
    end

    it "renders the search label and hint" do
      expect(rendered.text).to include("Search for a school in the list")
      expect(rendered.text).to include("You can also enter a postcode or URN")
    end

    it "renders a live region for announcing the number of results" do
      expect(rendered.at_css("[role='status']")["aria-live"]).to eq("polite")
    end

    it "carries the announcement wording for the controller to fill in" do
      status = rendered.at_css("[role='status']")

      expect(status["data-results-one"]).to eq("1 school found")
      expect(status["data-results-other"]).to eq("{count} schools found")
    end
  end

  describe "the no results message" do
    it "is hidden until a search returns nothing" do
      expect(rendered.at_css(".app-school-search__no-results").attributes).to have_key("hidden")
    end

    it "tells the provider how to recover" do
      expect(rendered.css(".app-school-search__no-results").text)
        .to include("No results found. Clear your search and try again.")
    end

    it "offers a way back to the full list" do
      expect(rendered.css(".app-school-search__no-results .app-button-link").text)
        .to include("Show all schools")
    end
  end
end
