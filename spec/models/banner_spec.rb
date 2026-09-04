require "rails_helper"

RSpec.describe Banner, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(2) }

    describe "word limits" do
      it "rejects a name longer than 20 words" do
        banner = build(:banner, name: "word " * 21)

        expect(banner).not_to be_valid
        expect(banner.errors[:name]).to include("Banner name must be 20 words or fewer")
      end

      it "rejects a heading longer than 30 words" do
        banner = build(:banner, heading: "word " * 31)

        expect(banner).not_to be_valid
        expect(banner.errors[:heading]).to include("Banner heading must be 30 words or fewer")
      end

      it "rejects a body longer than 200 words" do
        banner = build(:banner, body: "word " * 201)

        expect(banner).not_to be_valid
        expect(banner.errors[:body]).to include("The body of the banner must be 200 words or fewer")
      end
    end

    it "tells a support user what to enter rather than repeating can't be blank" do
      banner = described_class.new

      banner.validate

      expect(banner.errors[:name]).to include("Enter a name for the banner")
      expect(banner.errors[:body]).to include("Enter the body of the banner")
      expect(banner.errors[:published_at]).to include("Enter a publish date and time")
    end

    describe "displayed_on" do
      it "is invalid when no interface is selected" do
        banner = build(:banner, display_on_find: false, display_on_publish: false, display_on_support: false)

        expect(banner).not_to be_valid
        expect(banner.errors[:display_on_find]).to contain_exactly("Select at least one service to display the banner on")
      end
    end

    describe "expired_at" do
      it "is valid when expired_at is after published_at" do
        banner = build(:banner, published_at: 1.day.ago, expired_at: 1.day.from_now)
        expect(banner).to be_valid
      end

      it "is valid when expired_at equals published_at" do
        now = Time.current
        banner = build(:banner, published_at: now, expired_at: now)
        expect(banner).to be_valid
      end

      it "is invalid when expired_at is before published_at" do
        banner = build(:banner, published_at: 1.day.from_now, expired_at: 1.day.ago)
        expect(banner).not_to be_valid
        expect(banner.errors[:expired_at]).to contain_exactly("Expiry date must be the same as or after the publish date")
      end

      it "is valid when expired_at is nil" do
        banner = build(:banner, published_at: 1.day.ago, expired_at: nil)
        expect(banner).to be_valid
      end
    end
  end

  describe ".display_on_find" do
    it "returns only banners with display_on_find set to true" do
      find_banner = create(:banner, display_on_find: true)
      create(:banner, display_on_find: false)

      expect(described_class.display_on_find).to contain_exactly(find_banner)
    end
  end

  describe ".display_on_publish" do
    it "returns only banners with display_on_publish set to true" do
      publish_banner = create(:banner, display_on_publish: true)
      create(:banner, display_on_publish: false, display_on_find: true)

      expect(described_class.display_on_publish).to contain_exactly(publish_banner)
    end
  end

  describe ".display_on_support" do
    it "returns only banners with display_on_support set to true" do
      support_banner = create(:banner, display_on_support: true)
      create(:banner, display_on_support: false)

      expect(described_class.display_on_support).to contain_exactly(support_banner)
    end
  end

  describe "#displayed_on" do
    it "returns all interfaces when all are enabled" do
      banner = build(:banner, display_on_find: true, display_on_publish: true, display_on_support: true)
      expect(banner.displayed_on).to eq(%i[find publish support])
    end

    it "returns only enabled interfaces" do
      banner = build(:banner, display_on_find: true, display_on_publish: false, display_on_support: true)
      expect(banner.displayed_on).to eq(%i[find support])
    end

    it "returns an empty array when none are enabled" do
      banner = build(:banner, display_on_find: false, display_on_publish: false, display_on_support: false)
      expect(banner.displayed_on).to eq([])
    end

    it "returns an empty array when all are nil" do
      banner = build(:banner, display_on_find: nil, display_on_publish: nil, display_on_support: nil)
      expect(banner.displayed_on).to eq([])
    end
  end

  describe ".active" do
    it "returns the correct banners when checking active in the present" do
      timings = {
        present: Time.zone.local(2026, 7, 1, 12, 0, 0),
        past: Time.zone.local(2026, 7, 1, 11, 0, 0),
        future: Time.zone.local(2026, 7, 1, 13, 0, 0),
      }

      [
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

    it "ignores a banner whose expiry precedes its publication rather than failing the query" do
      banner = create(:banner, published_at: 1.day.ago, expired_at: nil)
      banner.update_columns(published_at: 2.days.from_now, expired_at: 1.day.ago)

      expect(described_class.active).to be_empty
    end
  end

  describe "#active?" do
    [
      { published: :future, expired: nil, result: false },
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

  describe ".scheduled" do
    it "returns the correct banners when checking scheduled in the present" do
      timings = {
        present: Time.zone.local(2026, 7, 1, 12, 0, 0),
        past: Time.zone.local(2026, 7, 1, 11, 0, 0),
        future: Time.zone.local(2026, 7, 1, 13, 0, 0),
      }

      [
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

  describe ".expired" do
    it "returns the correct banners when checking expired in the present" do
      timings = {
        present: Time.zone.local(2026, 7, 1, 12, 0, 0),
        past: Time.zone.local(2026, 7, 1, 11, 0, 0),
        future: Time.zone.local(2026, 7, 1, 13, 0, 0),
      }

      [
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

  describe "#status" do
    [

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
