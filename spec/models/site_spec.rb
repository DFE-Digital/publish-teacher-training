require "rails_helper"

describe Site, type: :model do
  include ActiveJob::TestHelper

  subject { create(:site) }

  describe "auditing" do
    it { should be_audited.associated_with(:provider) }
  end

  it { is_expected.to validate_presence_of(:location_name) }
  it { is_expected.to validate_presence_of(:address1) }
  it { is_expected.to validate_presence_of(:postcode) }
  it { is_expected.to validate_uniqueness_of(:location_name).scoped_to(:provider_id) }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive.scoped_to(:provider_id) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_inclusion_of(:code).in_array(Site::POSSIBLE_CODES).with_message("must be A-Z, 0-9 or -") }

  it "validates that URN cannot be letters" do
    subject.urn = "XXXXXX"
    subject.valid?
    expect(subject.errors[:urn]).to include("^URN must be 5 or 6 numbers")
  end

  it "validates URN minimum length" do
    subject.urn = "1234"
    subject.valid?
    expect(subject.errors[:urn]).to include("^URN must be 5 or 6 numbers")
  end

  it "validates URN maximum length" do
    subject.urn = "1234567"
    subject.valid?
    expect(subject.errors[:urn]).to include("^URN must be 5 or 6 numbers")
  end

  describe "associations" do
    it { should belong_to(:provider) }
  end

  describe "#touch_provider" do
    let(:site) { create(:site) }

    it "sets changed_at to the current time" do
      Timecop.freeze do
        site.touch
        expect(site.provider.changed_at).to eq Time.zone.now.utc
      end
    end

    it "leaves updated_at unchanged" do
      timestamp = 1.hour.ago
      site.provider.update! updated_at: timestamp
      site.touch
      expect(site.provider.updated_at).to eq timestamp
    end
  end

  describe "after running validation" do
    let(:site) { build(:site, provider: provider, code: nil) }
    let(:provider) { build(:provider) }
    subject { site }

    it "is assigned a valid code by default" do
      expect { subject.valid? }.to change { subject.code.blank? }.from(true).to(false)
      expect(subject.errors[:code]).to be_empty
    end

    it "is assigned easily-confused codes only when all others have been used up" do
      (Site::DESIRABLE_CODES - %w[A]).each { |code| create(:site, code: code, provider: provider) }
      subject.validate
      expect(subject.code).to eq("A")
    end
  end

  its(:recruitment_cycle) { should eq find(:recruitment_cycle) }

  describe "description" do
    subject { build(:site, location_name: "Foo", code: "1") }
    its(:to_s) { should eq "Foo (code: 1)" }
  end

  describe "geolocation" do
    after do
      clear_enqueued_jobs
      clear_performed_jobs
    end

    # Geocoding stubbed with support/helpers.rb
    let(:site) do
      build(:site,
            location_name: "Southampton High School",
            address1: "Long Lane",
            address2: "Holbury",
            address3: "Southampton",
            address4: nil,
            postcode: "SO45 2PA")
    end

    describe "#full_address" do
      context "location name is not 'Main site'" do
        it "includes location name in full address" do
          expect(site.full_address).to eq("Southampton High School, Long Lane, Holbury, Southampton, SO45 2PA")
        end
      end

      context "location name is 'Main site'" do
        before do
          site.location_name = "Main site"
        end

        it "excludes location name in full address" do
          expect(site.full_address).to eq("Long Lane, Holbury, Southampton, SO45 2PA")
        end
      end

      context "address is missing" do
        before do
          site.location_name = ""
          site.address1 = ""
          site.address2 = ""
          site.address3 = ""
          site.address4 = ""
          site.postcode = ""
        end

        it "returns an empty string" do
          expect(site.full_address).to eq("")
        end
      end
    end

    describe "#skip_geocoding" do
      before do
        site.provider = create(:provider, latitude: "foo", longitude: "bar")
        allow(GeocodeJob).to receive(:perform_later)
      end

      context "skip_geocoding is 'true'" do
        it "does not geocode" do
          site.skip_geocoding = true

          site.save!

          expect(GeocodeJob).to_not have_received(:perform_later)
        end
      end

      context "skip_geocoding is 'false'" do
        it "does not geocode" do
          site.skip_geocoding = false

          site.save!

          expect(GeocodeJob).to have_received(:perform_later)
        end
      end
    end

    describe "#needs_geolocation?" do
      subject { site.needs_geolocation? }

      context "latitude is nil" do
        let(:site) { build_stubbed(:site, latitude: nil) }

        it { should be(true) }
      end

      context "longitude is nil" do
        let(:site) { build_stubbed(:site, longitude: nil) }

        it { should be(true) }
      end

      context "latitude and longitude is not nil" do
        let(:site) { build_stubbed(:site, latitude: 1.456789, longitude: 1.456789) }

        it { should be(false) }
      end

      context "address" do
        let(:site) do
          create(:site,
                 latitude: 1.456789,
                 longitude: 1.456789,
                 location_name: "Southampton High School",
                 address1: "Long Lane",
                 address2: "Holbury",
                 address3: "Southampton",
                 address4: nil,
                 postcode: "SO45 2PA")
        end
        context "has not changed" do
          before do
            site.update(address1: "Long Lane")
          end

          it { should be(false) }
        end

        context "has changed" do
          before do
            site.update(address1: "New address 1")
          end

          it { should be(true) }
        end
      end
    end
  end

  describe "travel to work area and London Borough" do
    let(:site) do
      build(:site,
            latitude: 1.456789,
            longitude: 1.456789,
            location_name: "Southampton High School",
            address1: "Long Lane",
            address2: "Holbury",
            address3: "Southampton",
            address4: nil,
            postcode: "SO45 2PA")
    end

    after do
      clear_enqueued_jobs
      clear_performed_jobs
    end

    describe "#add_travel_to_work_area_and_london_borough?" do
      it "does not trigger add_travel_to_work_area_and_london_borough on after_commit if lat or long have not been updated" do
        expect(site).not_to receive(:add_travel_to_work_area_and_london_borough)
        site.latitude = nil
        site.longitude = nil
        site.save!
      end

      it "triggers add_travel_to_work_area_and_london_borough on after_commit if lat or long have been updated" do
        expect(site).to receive(:add_travel_to_work_area_and_london_borough)
        site.latitude = 1.5
        site.longitude = 1.4
        site.save!
      end
    end

    describe "#add_travel_to_work_area_and_london_borough" do
      before do
        allow(TravelToWorkAreaAndLondonBoroughJob).to receive(:perform_later)
        site.update!(latitude: 1.2, longitude: 1.3)
      end

      it "should call the TravelToWorkAreaAndLondonBoroughJob" do
        expect(TravelToWorkAreaAndLondonBoroughJob).to have_received(:perform_later).with(site.id)
      end
    end
  end
end
