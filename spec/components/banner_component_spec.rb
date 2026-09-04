# frozen_string_literal: true

require "rails_helper"

describe BannerComponent, type: :component do
  it "renders the body as markdown under a fixed title" do
    banner = build(:banner, body: "Read the [guidance](https://example.com).")

    result = render_inline(described_class.new(banner:))

    expect(result.css(".govuk-notification-banner__title").text).to include("Important")
    expect(result.css(".govuk-notification-banner__content a").attr("href").value).to eq("https://example.com")
  end

  it "titles at heading level two so it does not compete with the page heading" do
    banner = build(:banner)

    result = render_inline(described_class.new(banner:))

    expect(result.css("h2.govuk-notification-banner__title")).to be_present
  end

  it "renders the heading above the body when one is given" do
    banner = build(:banner, heading: "Applications close on Friday", body: "Check with the provider.")

    result = render_inline(described_class.new(banner:))

    expect(result.css("p.govuk-notification-banner__heading").text).to eq("Applications close on Friday")
    expect(result.css("p.govuk-body").text).to eq("Check with the provider.")
  end

  it "leaves out the heading element for a banner without one" do
    banner = build(:banner, heading: nil, body: "Check with the provider.")

    result = render_inline(described_class.new(banner:))

    expect(result.css("p.govuk-notification-banner__heading")).to be_empty
  end

  it "styles body links for the banner rather than the page" do
    banner = build(:banner, body: "Read the [service status page](https://example.com/status).")

    render_inline(described_class.new(banner:))

    expect(page.find("a")[:class]).to eq("govuk-notification-banner__link")
  end
end
