# frozen_string_literal: true

require "rails_helper"

describe BannerComponent, type: :component do
  it "renders the title, heading and body as markdown" do
    banner = build(:banner, title: "Important", heading: "Service update", body: "Read the [guidance](https://example.com).")

    result = render_inline(described_class.new(banner:))

    expect(result.css(".govuk-notification-banner__title").text).to include("Important")
    expect(result.css(".govuk-notification-banner__heading").text).to include("Service update")
    expect(result.css(".govuk-notification-banner__content a").attr("href").value).to eq("https://example.com")
  end

  it "titles at heading level two by default so it does not compete with the page heading" do
    banner = build(:banner, title_heading_level: nil)

    result = render_inline(described_class.new(banner:))

    expect(result.css("h2.govuk-notification-banner__title")).to be_present
  end

  it "titles at the level the banner asks for" do
    banner = build(:banner, title_heading_level: 3)

    result = render_inline(described_class.new(banner:))

    expect(result.css("h3.govuk-notification-banner__title")).to be_present
  end

  it "does not take focus on load the way a flash answering an action does" do
    banner = build(:banner, success_styling: true)

    result = render_inline(described_class.new(banner:))

    expect(result.css(".govuk-notification-banner").attr("data-disable-auto-focus").value).to eq("true")
  end

  it "uses success styling when the banner asks for it" do
    banner = build(:banner, success_styling: true)

    result = render_inline(described_class.new(banner:))

    expect(result.css(".govuk-notification-banner--success")).to be_present
  end
end
