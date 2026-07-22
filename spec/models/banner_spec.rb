require "rails_helper"

RSpec.describe Banner, type: :model do
  describe ".active" do
    it "returns the correct banners when checking active in the present" do
      timings = {
        present: Time.zone.local(2026, 7, 1, 12, 0, 0),
        past: Time.zone.local(2026, 7, 1, 11, 0, 0),
        future: Time.zone.local(2026, 7, 1, 13, 0, 0),
      }

      banner_setups = [
        { published: nil, expired: nil, name: :published_nil_and_expired_nil },
        { published: :past, expired: nil, name: :published_past_and_expired_nil },
        { published: :past, expired: :past, name: :published_past_and_expired_past },
        { published: :past, expired: :present, name: :published_past_and_expired_present },
        { published: :past, expired: :future, name: :published_past_and_expired_future },
        { published: :present, expired: nil, name: :published_present_and_expired_nil },
        { published: :present, expired: :present, name: :published_present_and_expired_present },
        { published: :present, expired: :future, name: :published_present_and_expired_future },
        { published: :future, expired: nil, name: :published_future_and_expired_nil },
        { published: :future, expired: :future, name: :published_future_and_expired_future },
      ].map do |banner_setup|
        published_at = timings.fetch(banner_setup[:published], nil)
        expired_at = timings.fetch(banner_setup[:expired], nil)

        banner = create(:banner, name: banner_setup[:name], published_at: published_at, expired_at: expired_at)
        banner_setup[:banner] = banner
        banner_setup
      end

      now = Time.zone.local(2026, 7, 1, 12, 0, 0) # matches present datetime
      expect(described_class.active(now).pluck(:name))
        .to contain_exactly(
          "published_past_and_expired_nil",
          "published_past_and_expired_present",
          "published_past_and_expired_future",
          "published_present_and_expired_nil",
          "published_present_and_expired_present",
          "published_present_and_expired_future",
        )

      expect(described_class.active(now).map { |banner| banner.active?(now) }).to be_all true
      active_banners = described_class.active(now)
      inactive_banners = described_class.all.excluding(active_banners)
      expect(inactive_banners.map { |banner| banner.active?(now) }).to be_all false
    end
  end

  describe "#active?" do
    [
      { published: nil, expired: nil, result: false },
      { published: nil, expired: :past, result: false },
      { published: nil, expired: :present, result: false },
      { published: nil, expired: :future, result: false },

      { published: :past, expired: nil, result: true },
      { published: :past, expired: :past, result: false },
      { published: :past, expired: :present, result: true },
      { published: :past, expired: :future, result: true },
      { published: :present, expired: nil, result: true },
      { published: :present, expired: :past, result: false },
      { published: :present, expired: :present, result: true },
      { published: :present, expired: :future, result: true },
      { published: :future, expired: nil, result: false },
      { published: :future, expired: :past, result: false },
      { published: :future, expired: :present, result: false },
      { published: :future, expired: :future, result: false },
    ].each do |expectation|
      context "when published_at is #{expectation[:published] || 'nil'} and expired_at is #{expectation[:expired] || 'nil'}" do
        it "returns #{expectation[:result]}" do
          timings = {
            now: Time.zone.local(2026, 7, 1, 12, 0, 0),
            present: Time.zone.local(2026, 7, 1, 12, 0, 0),
            past: Time.zone.local(2026, 7, 1, 11, 0, 0),
            future: Time.zone.local(2026, 7, 1, 13, 0, 0),
          }
          published_at = timings.fetch(expectation[:published], nil)
          expired_at = timings.fetch(expectation[:expired], nil)

          banner = build(:banner, published_at: published_at, expired_at: expired_at)
          expect(banner.active?(timings.fetch(:now))).to eq(expectation[:result])
        end
      end
    end
  end

  describe ".drafts" do
    it "returns the correct banners" do
      timings = {
        present: Time.zone.local(2026, 7, 1, 12, 0, 0),
        past: Time.zone.local(2026, 7, 1, 11, 0, 0),
        future: Time.zone.local(2026, 7, 1, 13, 0, 0),
      }

      banner_setups = [
        { published: nil, expired: nil, name: :published_nil_and_expired_nil },
        { published: :past, expired: nil, name: :published_past_and_expired_nil },
        { published: :past, expired: :past, name: :published_past_and_expired_past },
        { published: :past, expired: :future, name: :published_past_and_expired_future },
        { published: :present, expired: nil, name: :published_present_and_expired_nil },
        { published: :future, expired: nil, name: :published_future_and_expired_nil },
        { published: :future, expired: :future, name: :published_future_and_expired_future },
      ].map do |banner_setup|
        published_at = timings.fetch(banner_setup[:published], nil)
        expired_at = timings.fetch(banner_setup[:expired], nil)

        banner = create(:banner, name: banner_setup[:name], published_at: published_at, expired_at: expired_at)
        banner_setup[:banner] = banner
        banner_setup
      end

      expect(described_class.drafts.pluck(:name))
        .to contain_exactly("published_nil_and_expired_nil")

      expect(described_class.drafts.map(&:draft?)).to be_all true
      draft_banners = described_class.drafts
      non_draft_banners = described_class.all.excluding(draft_banners)
      expect(non_draft_banners.map(&:draft?)).to be_all false
    end
  end

  describe "#draft?" do
    [
      { published: nil, expired: nil, result: true },
      { published: nil, expired: :past, result: true },
      { published: nil, expired: :present, result: true },
      { published: nil, expired: :future, result: true },

      { published: :past, expired: nil, result: false },
      { published: :past, expired: :past, result: false },
      { published: :past, expired: :present, result: false },
      { published: :past, expired: :future, result: false },
      { published: :present, expired: nil, result: false },
      { published: :present, expired: :present, result: false },
      { published: :future, expired: nil, result: false },
      { published: :future, expired: :future, result: false },
    ].each do |expectation|
      context "when published_at is #{expectation[:published] || 'nil'} and expired_at is #{expectation[:expired] || 'nil'}" do
        it "returns #{expectation[:result]}" do
          timings = {
            present: Time.zone.local(2026, 7, 1, 12, 0, 0),
            past: Time.zone.local(2026, 7, 1, 11, 0, 0),
            future: Time.zone.local(2026, 7, 1, 13, 0, 0),
          }
          published_at = timings.fetch(expectation[:published], nil)
          expired_at = timings.fetch(expectation[:expired], nil)

          banner = build(:banner, published_at: published_at, expired_at: expired_at)
          expect(banner.draft?).to eq(expectation[:result])
        end
      end
    end
  end

  describe ".scheduled" do
    it "returns the correct banners when checking scheduled in the present" do
      timings = {
        present: Time.zone.local(2026, 7, 1, 12, 0, 0),
        past: Time.zone.local(2026, 7, 1, 11, 0, 0),
        future: Time.zone.local(2026, 7, 1, 13, 0, 0),
      }

      banner_setups = [
        { published: nil, expired: nil, name: :published_nil_and_expired_nil },
        { published: :past, expired: nil, name: :published_past_and_expired_nil },
        { published: :past, expired: :past, name: :published_past_and_expired_past },
        { published: :past, expired: :present, name: :published_past_and_expired_present },
        { published: :past, expired: :future, name: :published_past_and_expired_future },
        { published: :present, expired: nil, name: :published_present_and_expired_nil },
        { published: :present, expired: :present, name: :published_present_and_expired_present },
        { published: :present, expired: :future, name: :published_present_and_expired_future },
        { published: :future, expired: nil, name: :published_future_and_expired_nil },
        { published: :future, expired: :future, name: :published_future_and_expired_future },
      ].map do |banner_setup|
        published_at = timings.fetch(banner_setup[:published], nil)
        expired_at = timings.fetch(banner_setup[:expired], nil)

        banner = create(:banner, name: banner_setup[:name], published_at: published_at, expired_at: expired_at)
        banner_setup[:banner] = banner
        banner_setup
      end

      now = Time.zone.local(2026, 7, 1, 12, 0, 0)
      expect(described_class.scheduled(now).pluck(:name))
        .to contain_exactly(
          "published_future_and_expired_nil",
          "published_future_and_expired_future",
        )

      expect(described_class.scheduled(now).map { |banner| banner.scheduled?(now) }).to be_all true
      scheduled_banners = described_class.scheduled(now)
      non_scheduled_banners = described_class.all.excluding(scheduled_banners)
      expect(non_scheduled_banners.map { |banner| banner.scheduled?(now) }).to be_all false
    end
  end

  describe "#scheduled?" do
    [
      { published: nil, expired: nil, result: false },
      { published: nil, expired: :past, result: false },
      { published: nil, expired: :present, result: false },
      { published: nil, expired: :future, result: false },

      { published: :past, expired: nil, result: false },
      { published: :past, expired: :past, result: false },
      { published: :past, expired: :present, result: false },
      { published: :past, expired: :future, result: false },
      { published: :present, expired: nil, result: false },
      { published: :present, expired: :present, result: false },
      { published: :present, expired: :future, result: false },
      { published: :future, expired: nil, result: true },
      { published: :future, expired: :past, result: true },
      { published: :future, expired: :present, result: true },
      { published: :future, expired: :future, result: true },
    ].each do |expectation|
      context "when published_at is #{expectation[:published] || 'nil'} and expired_at is #{expectation[:expired] || 'nil'}" do
        it "returns #{expectation[:result]}" do
          timings = {
            now: Time.zone.local(2026, 7, 1, 12, 0, 0),
            present: Time.zone.local(2026, 7, 1, 12, 0, 0),
            past: Time.zone.local(2026, 7, 1, 11, 0, 0),
            future: Time.zone.local(2026, 7, 1, 13, 0, 0),
          }
          published_at = timings.fetch(expectation[:published], nil)
          expired_at = timings.fetch(expectation[:expired], nil)

          banner = build(:banner, published_at: published_at, expired_at: expired_at)
          expect(banner.scheduled?(timings.fetch(:now))).to eq(expectation[:result])
        end
      end
    end
  end

  describe ".expired" do
    it "returns the correct banners when checking expired in the present" do
      timings = {
        present: Time.zone.local(2026, 7, 1, 12, 0, 0),
        past: Time.zone.local(2026, 7, 1, 11, 0, 0),
        future: Time.zone.local(2026, 7, 1, 13, 0, 0),
      }

      banner_setups = [
        { published: nil, expired: nil, name: :published_nil_and_expired_nil },
        { published: :past, expired: nil, name: :published_past_and_expired_nil },
        { published: :past, expired: :past, name: :published_past_and_expired_past },
        { published: :past, expired: :present, name: :published_past_and_expired_present },
        { published: :past, expired: :future, name: :published_past_and_expired_future },
        { published: :present, expired: nil, name: :published_present_and_expired_nil },
        { published: :present, expired: :present, name: :published_present_and_expired_present },
        { published: :present, expired: :future, name: :published_present_and_expired_future },
        { published: :future, expired: nil, name: :published_future_and_expired_nil },
        { published: :future, expired: :future, name: :published_future_and_expired_future },
      ].map do |banner_setup|
        published_at = timings.fetch(banner_setup[:published], nil)
        expired_at = timings.fetch(banner_setup[:expired], nil)

        banner = create(:banner, name: banner_setup[:name], published_at: published_at, expired_at: expired_at)
        banner_setup[:banner] = banner
        banner_setup
      end

      now = Time.zone.local(2026, 7, 1, 12, 0, 0)
      expect(described_class.expired(now).pluck(:name))
        .to contain_exactly("published_past_and_expired_past")

      expect(described_class.expired(now).map { |banner| banner.expired?(now) }).to be_all true
      expired_banners = described_class.expired(now)
      non_expired_banners = described_class.all.excluding(expired_banners)
      expect(non_expired_banners.map { |banner| banner.expired?(now) }).to be_all false
    end
  end

  describe "#expired?" do
    [
      { published: nil, expired: nil, result: false },
      { published: nil, expired: :past, result: false },
      { published: nil, expired: :present, result: false },
      { published: nil, expired: :future, result: false },

      { published: :past, expired: nil, result: false },
      { published: :past, expired: :past, result: true },
      { published: :past, expired: :present, result: false },
      { published: :past, expired: :future, result: false },
      { published: :present, expired: nil, result: false },
      { published: :present, expired: :past, result: true },
      { published: :present, expired: :present, result: false },
      { published: :present, expired: :future, result: false },
      { published: :future, expired: nil, result: false },
      { published: :future, expired: :past, result: false },
      { published: :future, expired: :present, result: false },
      { published: :future, expired: :future, result: false },
    ].each do |expectation|
      context "when published_at is #{expectation[:published] || 'nil'} and expired_at is #{expectation[:expired] || 'nil'}" do
        it "returns #{expectation[:result]}" do
          timings = {
            now: Time.zone.local(2026, 7, 1, 12, 0, 0),
            present: Time.zone.local(2026, 7, 1, 12, 0, 0),
            past: Time.zone.local(2026, 7, 1, 11, 0, 0),
            future: Time.zone.local(2026, 7, 1, 13, 0, 0),
          }
          published_at = timings.fetch(expectation[:published], nil)
          expired_at = timings.fetch(expectation[:expired], nil)

          banner = build(:banner, published_at: published_at, expired_at: expired_at)
          expect(banner.expired?(timings.fetch(:now))).to eq(expectation[:result])
        end
      end
    end
  end

  describe "#status" do
    [
      { published: nil, expired: nil, result: :draft },
      { published: nil, expired: :past, result: :draft },
      { published: nil, expired: :future, result: :draft },

      { published: :past, expired: nil, result: :active },
      { published: :past, expired: :past, result: :expired },
      { published: :past, expired: :present, result: :active },
      { published: :past, expired: :future, result: :active },
      { published: :present, expired: nil, result: :active },
      { published: :present, expired: :present, result: :active },
      { published: :present, expired: :future, result: :active },
      { published: :future, expired: nil, result: :scheduled },
      { published: :future, expired: :future, result: :scheduled },
    ].each do |expectation|
      context "when published_at is #{expectation[:published] || 'nil'} and expired_at is #{expectation[:expired] || 'nil'}" do
        it "returns :#{expectation[:result]}" do
          timings = {
            now: Time.zone.local(2026, 7, 1, 12, 0, 0),
            present: Time.zone.local(2026, 7, 1, 12, 0, 0),
            past: Time.zone.local(2026, 7, 1, 11, 0, 0),
            future: Time.zone.local(2026, 7, 1, 13, 0, 0),
          }
          published_at = timings.fetch(expectation[:published], nil)
          expired_at = timings.fetch(expectation[:expired], nil)

          banner = build(:banner, published_at: published_at, expired_at: expired_at)
          expect(banner.status(timings.fetch(:now))).to eq(expectation[:result])
        end
      end
    end
  end
end
