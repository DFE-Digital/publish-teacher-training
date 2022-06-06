require "rails_helper"

module PhaseBanner
  RSpec.describe View, type: :component do
    {
      "development" => "grey",
      "qa" => "orange",
      "review" => "purple",
      "sandbox" => "purple",
      "rollover" => "turquoise",
      "staging" => "red",
      "unknown-environment" => "yellow",
    }.each do |environment, colour|
      it "renders a #{colour} phase banner for the #{environment} environment" do
        allow(Settings.environment).to receive(:name).and_return(environment)
        render_inline(described_class.new)

        expect(page).to have_selector(".govuk-phase-banner .govuk-tag--#{colour}")
      end
    end

    it "renders sandbox message text if in sandbox_mode" do
      allow(Settings.environment).to receive(:name).and_return("sandbox")
      render_inline(described_class.new)
      expect(page).to have_text("This is a test version of Publish for providers")
    end

    it "renders default message text if in any mode other than sandbox" do
      allow(Settings.environment).to receive(:name).and_return("review")
      render_inline(described_class.new)
      expect(page).to have_text("This is a new service")
    end

    context "when no value is passed in to 'no_border'" do
      it "renders a border" do
        render_inline(described_class.new)
        expect(page).not_to have_css(".app-phase-banner--no-border")
      end
    end

    context "when true is passed in to 'no_border'" do
      it "does not render a border" do
        render_inline(described_class.new(no_border: true))
        expect(page).to have_css(".app-phase-banner--no-border")
      end
    end
  end
end
