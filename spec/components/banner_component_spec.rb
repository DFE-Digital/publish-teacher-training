# frozen_string_literal: true

require "rails_helper"

describe BannerComponent, type: :component do
  it "renders the heading and body as markdown under a fixed title" do
    banner = build(:banner, heading: "Service update", body: "Read the [guidance](https://example.com).")

    result = render_inline(described_class.new(banner:))

    expect(result.css(".govuk-notification-banner__title").text).to include("Important")
    expect(result.css(".govuk-notification-banner__heading").text).to include("Service update")
    expect(result.css(".govuk-notification-banner__content a").attr("href").value).to eq("https://example.com")
  end

  it "titles at heading level two so it does not compete with the page heading" do
    banner = build(:banner)

    result = render_inline(described_class.new(banner:))

    expect(result.css("h2.govuk-notification-banner__title")).to be_present
  end

  it "styles body links for the banner rather than the page" do
    banner = build(:banner, body: "Read the [service status page](https://example.com/status).")

    render_inline(described_class.new(banner:))

    expect(page.find("a")[:class]).to eq("govuk-notification-banner__link")
  end
end
