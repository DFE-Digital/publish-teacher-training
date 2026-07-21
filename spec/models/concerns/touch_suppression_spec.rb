# frozen_string_literal: true

require "rails_helper"

describe TouchSuppression do
  it "is not suppressed by default" do
    expect(described_class).not_to be_suppressed
  end

  it "suppresses within the block and restores afterwards" do
    described_class.suppress do
      expect(described_class).to be_suppressed
    end

    expect(described_class).not_to be_suppressed
  end

  it "restores when the block raises" do
    expect { described_class.suppress { raise "boom" } }.to raise_error("boom")

    expect(described_class).not_to be_suppressed
  end

  it "stays suppressed until the outermost block ends when nested" do
    described_class.suppress do
      described_class.suppress { nil }

      expect(described_class).to be_suppressed
    end

    expect(described_class).not_to be_suppressed
  end

  describe "a suppressed record" do
    let(:provider) { create(:provider) }
    let(:site) { create(:site, provider:) }

    it "does not touch its provider" do
      site
      provider.update_columns(changed_at: 2.years.ago)

      described_class.suppress { site.update!(location_name: "Renamed") }

      expect(provider.reload.changed_at).to be_within(1.minute).of(2.years.ago)
    end

    it "touches its provider when not suppressed" do
      site
      provider.update_columns(changed_at: 2.years.ago)

      site.update!(location_name: "Renamed")

      expect(provider.reload.changed_at).to be_within(1.minute).of(Time.zone.now)
    end
  end
end
