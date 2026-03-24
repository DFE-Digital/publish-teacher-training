# frozen_string_literal: true

require "rails_helper"

RSpec.describe Candidate::EmailAlert, type: :model do
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
      email_alert = build(:email_alert, subjects: [], search_attributes: { "level" => "primary" })

      result = email_alert.search_params

      expect(result).to eq(level: "primary")
    end
  end

  describe "#matches_search?" do
    let(:search_attributes) do
      {
        "level" => "further_education",
        "send_courses" => "true",
        "qualifications" => %w[qts qts_with_pgce_or_pgde],
        "minimum_degree_required" => "two_one",
        "can_sponsor_visa" => "true",
        "interview_location" => "online",
        "start_date" => %w[jan_to_aug september oct_to_jul],
      }
    end

    it "matches when subjects and search_attributes are identical" do
      alert = build(:email_alert, subjects: %w[C1 F1 W1 L1 13 W3], search_attributes:)

      expect(alert.matches_search?(subjects: %w[C1 F1 W1 L1 13 W3], search_attributes:)).to be true
    end

    it "matches regardless of subject order" do
      alert = build(:email_alert, subjects: %w[13 C1 F1 L1 W1 W3], search_attributes:)

      expect(alert.matches_search?(subjects: %w[W3 C1 13 F1 L1 W1], search_attributes:)).to be true
    end

    it "does not match when subjects differ" do
      alert = build(:email_alert, subjects: %w[C1 F1], search_attributes:)

      expect(alert.matches_search?(subjects: %w[C1], search_attributes:)).to be false
    end

    it "does not match when search_attributes differ" do
      alert = build(:email_alert, subjects: %w[C1], search_attributes:)

      different_attrs = search_attributes.merge("level" => "secondary")
      expect(alert.matches_search?(subjects: %w[C1], search_attributes: different_attrs)).to be false
    end

    it "does not match an unsubscribed alert via active scope" do
      candidate = create(:candidate)
      alert = create(:email_alert, candidate:, subjects: %w[C1], search_attributes:)
      alert.unsubscribe!

      expect(
        candidate.email_alerts.active
          .pluck(:subjects, :search_attributes)
          .map { |s, a| [s.sort, a] }
          .to_set
          .include?([%w[C1], search_attributes]),
      ).to be false
    end

    it "ignores return_to key in search_attributes" do
      alert = build(:email_alert, subjects: %w[C1], search_attributes:)

      expect(alert.matches_search?(subjects: %w[C1], search_attributes: search_attributes.merge("return_to" => "recent_searches"))).to be true
    end

    it "matches when alert has string 'true' and recent search has boolean true" do
      # Email alerts store "true" (string via strong params)
      # Recent searches store true (boolean via JSONB)
      alert_attrs = { "can_sponsor_visa" => "true", "send_courses" => "true", "level" => "further_education" }
      recent_attrs = { "can_sponsor_visa" => true, "send_courses" => true, "level" => "further_education" }

      alert = create(:email_alert, subjects: %w[C1], search_attributes: alert_attrs).reload

      # Verify the type mismatch exists
      expect(alert.search_attributes["can_sponsor_visa"]).to be_a(String)
      expect(recent_attrs["can_sponsor_visa"]).to be(true)

      expect(alert.matches_search?(subjects: %w[C1], search_attributes: recent_attrs)).to be true
    end

    it "matches via filter_key when types differ between alert and recent search" do
      alert_attrs = { "can_sponsor_visa" => "true", "send_courses" => "true", "level" => "further_education" }
      recent_attrs = { "can_sponsor_visa" => true, "send_courses" => true, "level" => "further_education" }

      alert = create(:email_alert, subjects: %w[C1], search_attributes: alert_attrs).reload

      alert_key = alert.filter_key
      normalized_recent_attrs = Find::FilterKeyDigest.normalize(recent_attrs)
      recent_key = [%w[C1], normalized_recent_attrs]

      expect(Set[alert_key].include?(recent_key)).to be true
    end

    it "matches when alert is missing a display-only key present in the recent search" do
      alert = build(:email_alert, subjects: %w[C1], search_attributes: {
        "level" => "further_education",
        "can_sponsor_visa" => "true",
      })

      recent_attrs = {
        "level" => "further_education",
        "can_sponsor_visa" => "true",
        "location" => "Manchester",
        "radius" => "50",
        "order" => "distance",
      }

      expect(alert.matches_search?(subjects: %w[C1], search_attributes: recent_attrs)).to be true
    end
  end

  describe "subscription limit validation" do
    it "is valid when below the subscription limit" do
      candidate = create(:candidate)
      stub_const("Candidate::EmailAlert::MAXIMUM_SUBSCRIPTIONS", 2)
      create(:email_alert, candidate:)

      email_alert = build(:email_alert, candidate:)

      expect(email_alert).to be_valid
    end

    it "is invalid when the subscription limit is reached" do
      candidate = create(:candidate)
      stub_const("Candidate::EmailAlert::MAXIMUM_SUBSCRIPTIONS", 2)
      create_list(:email_alert, 2, candidate:)

      email_alert = build(:email_alert, candidate:)

      expect(email_alert).not_to be_valid
      expect(email_alert.errors).to be_of_kind(:base, :subscription_limit_reached)
    end

    it "does not prevent updating an existing alert when at the limit" do
      candidate = create(:candidate)
      stub_const("Candidate::EmailAlert::MAXIMUM_SUBSCRIPTIONS", 2)
      alerts = create_list(:email_alert, 2, candidate:)

      alerts.first.unsubscribe!

      expect(alerts.first).to be_valid
    end

    it "does not count unsubscribed email alerts" do
      candidate = create(:candidate)
      stub_const("Candidate::EmailAlert::MAXIMUM_SUBSCRIPTIONS", 2)
      alerts = create_list(:email_alert, 2, candidate:)
      alerts.first.unsubscribe!

      email_alert = build(:email_alert, candidate:)

      expect(email_alert).to be_valid
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
