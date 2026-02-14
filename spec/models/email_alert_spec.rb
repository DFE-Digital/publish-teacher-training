# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmailAlert, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:candidate) }
  end

  describe "scopes" do
    describe ".active" do
      it "returns only records where unsubscribed_at is nil" do
        active = create(:email_alert)
        unsubscribed = create(:email_alert)
        unsubscribed.unsubscribe!

        expect(described_class.active).to contain_exactly(active)
      end
    end

    describe ".subscribed" do
      it "is an alias for active" do
        active = create(:email_alert)
        unsubscribed = create(:email_alert)
        unsubscribed.unsubscribe!

        expect(described_class.subscribed).to contain_exactly(active)
      end
    end
  end

  describe "validation" do
    it "accepts valid search_attributes keys" do
      email_alert = build(:email_alert, search_attributes: { "funding" => "salary", "level" => "secondary" })

      expect(email_alert).to be_valid
    end

    it "accepts empty search_attributes" do
      email_alert = build(:email_alert, search_attributes: {})

      expect(email_alert).to be_valid
    end

    it "rejects unknown search_attributes keys" do
      email_alert = build(:email_alert, search_attributes: { "bogus_key" => "value" })

      expect(email_alert).not_to be_valid
      expect(email_alert.errors[:search_attributes].first).to include("bogus_key")
    end
  end

  describe "#search_params" do
    it "merges denormalized columns with search_attributes" do
      email_alert = build(
        :email_alert,
        subjects: %w[C1 F1],
        longitude: -1.5,
        latitude: 53.0,
        radius: 20,
        search_attributes: { "funding" => "salary" },
      )

      result = email_alert.search_params

      expect(result).to eq(
        funding: "salary",
        subjects: %w[C1 F1],
        longitude: -1.5,
        latitude: 53.0,
        radius: 20,
      )
    end

    it "omits blank denormalized columns" do
      email_alert = build(:email_alert, search_attributes: { "level" => "primary" })

      result = email_alert.search_params

      expect(result).to eq(level: "primary")
    end
  end

  describe "#unsubscribe!" do
    it "sets unsubscribed_at to the current time" do
      email_alert = create(:email_alert)

      freeze_time do
        email_alert.unsubscribe!

        expect(email_alert.unsubscribed_at).to eq(Time.current)
      end
    end

    it "makes the alert inactive" do
      email_alert = create(:email_alert)
      email_alert.unsubscribe!

      expect(described_class.active).not_to include(email_alert)
    end
  end
end
