require "rails_helper"

RSpec.describe PhaseBanner::View, type: :component do
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

  it "renders different message text if in sandbox_mode" do
    allow(Settings.environment).to receive(:name).and_return("sandbox")
    render_inline(described_class.new)
    expect(page).to have_text("This is a test version of Publish for providers")

    allow(Settings.environment).to receive(:name).and_return("review")
    render_inline(described_class.new)
    expect(page).to have_text("This is a new service")
  end
end
