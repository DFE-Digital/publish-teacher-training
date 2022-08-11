require "rails_helper"

module FindInterface
  module PhaseBanner
    RSpec.describe View, type: :component do
      {
        "development" => "grey",
        "qa" => "orange",
        "review" => "purple",
        "sandbox" => "purple",
        "staging" => "red",
        "unknown-environment" => "yellow",
      }.each do |environment, colour|
        it "renders a #{colour} phase banner for the #{environment} environment" do
          allow(Settings.environment).to receive(:name).and_return(environment)
          render_inline(described_class.new)

          expect(page).to have_selector(".govuk-phase-banner .govuk-tag--#{colour}")
        end
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
end
