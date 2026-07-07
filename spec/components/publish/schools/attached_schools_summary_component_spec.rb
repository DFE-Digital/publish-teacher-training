require "rails_helper"

RSpec.describe Publish::Schools::AttachedSchoolsSummaryComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(course:)) }

  let(:course) { build_stubbed(:course).decorate }

  def stub_school_names(names)
    allow(course).to receive(:sorted_school_names).and_return(names)
  end

  context "when there are no schools" do
    before { stub_school_names([]) }

    it "renders a muted None" do
      expect(rendered.css(".app-\\!-colour-muted").text).to eq("None")
    end

    it "does not render a details component or a list" do
      expect(rendered.css("details")).to be_empty
      expect(rendered.css("ul")).to be_empty
    end
  end

  context "when there is a single school" do
    before { stub_school_names(["Greenhill Academy"]) }

    it "renders the school name inline without a list or details" do
      expect(rendered.text).to include("Greenhill Academy")
      expect(rendered.css("ul")).to be_empty
      expect(rendered.css("details")).to be_empty
    end
  end

  context "when there are 5 schools (at the threshold)" do
    let(:names) { Array.new(5) { |i| "School #{i + 1}" } }

    before { stub_school_names(names) }

    it "renders a plain list, not a details component" do
      expect(rendered.css("ul.govuk-list li").map(&:text)).to eq(names)
      expect(rendered.css("details")).to be_empty
    end
  end

  context "when there are 6 or more schools" do
    let(:names) { Array.new(6) { |i| "School #{i + 1}" } }

    before { stub_school_names(names) }

    it "wraps the list in a details component" do
      expect(rendered.css("details ul.govuk-list li").map(&:text)).to eq(names)
    end

    it "uses the school count as the summary link text" do
      expect(rendered.css("details summary").text).to include("6 schools attached")
    end
  end
end
