# frozen_string_literal: true

require "rails_helper"

RSpec.describe FilterKeyDigestable do
  describe "digest computation" do
    it "sets filter_key_digest on create for EmailAlert" do
      alert = create(:email_alert, subjects: %w[C1 F1], search_attributes: { "level" => "secondary" })

      expect(alert.filter_key_digest).to be_present
      expect(alert.filter_key_digest).to eq(alert.compute_filter_key_digest)
    end

    it "sets filter_key_digest on create for RecentSearch" do
      search = create(:recent_search, subjects: %w[C1], search_attributes: { "funding" => "salary" })

      expect(search.filter_key_digest).to be_present
      expect(search.filter_key_digest).to eq(search.compute_filter_key_digest)
    end

    it "produces the same digest for the same subjects and search_attributes" do
      attrs = { "level" => "secondary", "can_sponsor_visa" => "true" }
      alert = create(:email_alert, subjects: %w[C1 F1], search_attributes: attrs)
      search = create(:recent_search, subjects: %w[F1 C1], search_attributes: attrs)

      expect(alert.filter_key_digest).to eq(search.filter_key_digest)
    end

    it "produces the same digest regardless of subject order" do
      attrs = { "level" => "secondary" }
      alert1 = create(:email_alert, subjects: %w[C1 F1], search_attributes: attrs)
      alert2 = create(:email_alert, subjects: %w[F1 C1], search_attributes: attrs)

      expect(alert1.filter_key_digest).to eq(alert2.filter_key_digest)
    end

    it "produces different digests for different subjects" do
      attrs = { "level" => "secondary" }
      alert1 = create(:email_alert, subjects: %w[C1], search_attributes: attrs)
      alert2 = create(:email_alert, subjects: %w[F1], search_attributes: attrs)

      expect(alert1.filter_key_digest).not_to eq(alert2.filter_key_digest)
    end

    it "produces different digests for different search_attributes" do
      alert1 = create(:email_alert, subjects: %w[C1], search_attributes: { "level" => "secondary" })
      alert2 = create(:email_alert, subjects: %w[C1], search_attributes: { "level" => "primary" })

      expect(alert1.filter_key_digest).not_to eq(alert2.filter_key_digest)
    end

    it "ignores display-only keys in search_attributes" do
      alert1 = create(:email_alert, subjects: %w[C1], search_attributes: { "level" => "secondary" })
      alert2 = create(:email_alert, subjects: %w[C1], search_attributes: { "level" => "secondary", "location" => "London" })

      expect(alert1.filter_key_digest).to eq(alert2.filter_key_digest)
    end

    it "handles nil search_attributes" do
      alert = build(:email_alert, subjects: %w[C1], search_attributes: nil)
      # Manually bypass validation to test nil handling
      alert.instance_variable_set(:@search_attributes_override, true)

      expect(alert.compute_filter_key_digest).to be_present
    end

    it "normalizes boolean-like values to strings" do
      alert = create(:email_alert, subjects: %w[C1], search_attributes: { "can_sponsor_visa" => "true" })
      search = create(:recent_search, subjects: %w[C1], search_attributes: { "can_sponsor_visa" => true })

      expect(alert.filter_key_digest).to eq(search.filter_key_digest)
    end
  end

  describe "callback conditions" do
    it "recomputes digest when subjects change" do
      alert = create(:email_alert, subjects: %w[C1], search_attributes: { "level" => "secondary" })
      original_digest = alert.filter_key_digest

      alert.update!(subjects: %w[C1 F1])

      expect(alert.filter_key_digest).not_to eq(original_digest)
    end

    it "recomputes digest when search_attributes change" do
      alert = create(:email_alert, subjects: %w[C1], search_attributes: { "level" => "secondary" })
      original_digest = alert.filter_key_digest

      alert.update!(search_attributes: { "level" => "primary" })

      expect(alert.filter_key_digest).not_to eq(original_digest)
    end

    it "does not recompute digest when unrelated columns change" do
      alert = create(:email_alert, subjects: %w[C1], search_attributes: { "level" => "secondary" })
      original_digest = alert.filter_key_digest

      alert.unsubscribe!

      expect(alert.filter_key_digest).to eq(original_digest)
    end
  end
end
