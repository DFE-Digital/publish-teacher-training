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

  it "leads with the first line styled as the banner's own heading" do
    banner = build(:banner, body: "Applications close on Friday.\n\nCheck with the provider.")

    result = render_inline(described_class.new(banner:))

    expect(result.css("p.govuk-notification-banner__heading").text).to eq("Applications close on Friday.")
    expect(result.css("p.govuk-body").text).to eq("Check with the provider.")
  end

  it "leaves a body that opens with a list alone rather than promoting a later paragraph" do
    banner = build(:banner, body: "- first point\n- second point\n\nAfter the list.")

    result = render_inline(described_class.new(banner:))

    expect(result.css("p.govuk-notification-banner__heading")).to be_empty
    expect(result.css("p.govuk-body").text).to eq("After the list.")
  end

  it "styles body links for the banner rather than the page" do
    banner = build(:banner, body: "Read the [service status page](https://example.com/status).")

    render_inline(described_class.new(banner:))

    expect(page.find("a")[:class]).to eq("govuk-notification-banner__link")
  end
end
