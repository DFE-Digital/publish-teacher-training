# frozen_string_literal: true

require "rails_helper"

describe ActiveBannersComponent, type: :component do
  it "renders only the active banners for its own interface" do
    create(:banner, body: "For Find", published_at: 1.day.ago, display_on_find: true, display_on_publish: false)
    create(:banner, body: "For Publish", published_at: 1.day.ago, display_on_publish: true)
    create(:banner, body: "Not yet live", published_at: 1.day.from_now, display_on_find: true, display_on_publish: false)
    create(:banner, body: "Long gone", published_at: 2.days.ago, expired_at: 1.day.ago, display_on_find: true, display_on_publish: false)

    result = render_inline(described_class.new(interface: :find, flash: {}))

    expect(result.text).to include("For Find")
    expect(result.text).not_to include("For Publish")
    expect(result.text).not_to include("Not yet live")
    expect(result.text).not_to include("Long gone")
  end

  it "shows the most recently published banner first" do
    create(:banner, body: "Published earlier", published_at: 2.days.ago)
    create(:banner, body: "Published later", published_at: 1.day.ago)

    result = render_inline(described_class.new(interface: :publish, flash: {}))

    expect(result.text.index("Published later")).to be < result.text.index("Published earlier")
  end

  it "stands aside for a flash message rather than stacking two banners" do
    create(:banner, body: "Service update", published_at: 1.day.ago)

    result = render_inline(described_class.new(interface: :publish, flash: { success: "Saved" }))

    expect(result.text).to be_blank
  end

  it "renders nothing when no banner is active" do
    result = render_inline(described_class.new(interface: :publish, flash: {}))

    expect(result.text).to be_blank
  end

  it "refuses an interface it does not know" do
    expect { render_inline(described_class.new(interface: :nonsense, flash: {})) }.to raise_error(KeyError)
  end

  it "labels each banner with its own title so several on a page stay distinguishable" do
    create(:banner, body: "First", published_at: 2.days.ago)
    create(:banner, body: "Second", published_at: 1.day.ago)

    result = render_inline(described_class.new(interface: :publish, flash: {}))

    labelled_by = result.css(".govuk-notification-banner").map { |banner| banner["aria-labelledby"] }
    title_ids = result.css(".govuk-notification-banner__title").map { |title| title["id"] }

    expect(title_ids.uniq.size).to eq(2)
    expect(labelled_by).to eq(title_ids)
  end
end
