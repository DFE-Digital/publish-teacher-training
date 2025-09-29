# frozen_string_literal: true

require "rails_helper"

describe Site do
  include ActiveJob::TestHelper

  subject { create(:site, provider_id: provider.id) }

  let(:provider) { create(:provider) }

  describe "auditing" do
    it { is_expected.to be_audited.associated_with(:provider) }
  end

  describe "school" do
    it { is_expected.to validate_presence_of(:location_name) }
    it { is_expected.to validate_presence_of(:address1) }
    it { is_expected.not_to validate_presence_of(:town).on(:create) }
    it { is_expected.to validate_presence_of(:postcode) }
  end

  describe "study_site" do
    subject { create(:site, :study_site, provider_id: provider.id) }

    it { is_expected.to validate_presence_of(:location_name) }
    it { is_expected.to validate_presence_of(:address1) }
    it { is_expected.to validate_presence_of(:town).on(:create) }
    it { is_expected.to validate_presence_of(:postcode) }
  end

  describe "uniqueness validation with discarded records" do
    let(:existing_site) { create(:site, location_name: "Test School", provider: provider, site_type: "school") }

    before do
      existing_site.discard!
    end

    it "allows creating a new site with the same name as a discarded site" do
      new_site = build(:site, location_name: "Test School", provider: provider, site_type: "school")
      expect(new_site).to be_valid
      expect { new_site.save! }.not_to raise_error
    end

    it "allows creating duplicate schools with the same name under the same provider" do
      new_school = build(:site, location_name: "Test Study Site", provider: provider, site_type: "school")

      expect(new_school).to be_valid
      expect { new_school.save! }.not_to raise_error
    end

    it "prevents creating duplicate study sites when the original is not discarded" do
      create(:site, location_name: "Test Study Site", provider: provider, site_type: "study_site")
      new_site = build(:site, location_name: "Test Study Site", provider: provider, site_type: "study_site")

      expect(new_site).not_to be_valid
      expect(new_site.errors[:location_name]).to include("This study site has already been added")
    end

    context "with different site types" do
      it "allows same name for different site types even when one is discarded" do
        study_site = build(:site, :study_site, location_name: "Test School", provider: provider)
        expect(study_site).to be_valid
      end
    end
  end

  it "validates that URN cannot be letters" do
    subject.urn = "XXXXXX"
    subject.valid?
    expect(subject.errors[:urn]).to include("Site URN must be 5 or 6 numbers")
  end

  it "validates URN minimum length" do
    subject.urn = "1234"
    subject.valid?
    expect(subject.errors[:urn]).to include("Site URN must be 5 or 6 numbers")
  end

  it "validates URN maximum length" do
    subject.urn = "1234567"
    subject.valid?
    expect(subject.errors[:urn]).to include("Site URN must be 5 or 6 numbers")
  end

  it "has a uuid" do
    expect(subject.uuid).to be_present
  end

  describe "associations" do
    it { is_expected.to belong_to(:provider) }

    it { is_expected.to have_many(:study_site_placements) }
  end

  describe "discarded behaviour for code" do
    subject { create(:site, provider_id: provider.id, code: "B") }

    let(:existing_code) { "AB" }
    let(:site_with_code) { create(:site, code: existing_code, provider_id: provider.id) }

    before do
      site_with_code.discard!
      subject.code = existing_code
    end

    it "can be saved with a discarded code" do
      expect { subject.save! }.not_to raise_error
      expect(subject.reload.code).to eq(existing_code)
    end
  end

  describe "#has_no_course?" do
    let(:site) { create(:site) }

    context "with no course" do
      it "is true if no associcated course" do
        expect(site.has_no_course?).to be true
      end
    end

    context "with an associated course" do
      let(:course) { create(:course) }

      it "is false with associcated course" do
        course.sites << site
        expect(site.has_no_course?).to be false
      end
    end
  end

  describe "#touch_provider" do
    let(:site) { create(:site) }

    it "sets changed_at to the current time" do
      Timecop.freeze do
        site.touch
        expect(site.provider.changed_at).to be_within(1.second).of(Time.now.utc)
      end
    end

    it "leaves updated_at unchanged" do
      timestamp = 1.hour.ago
      site.provider.update updated_at: timestamp
      site.touch
      expect(site.provider.updated_at).to be_within(1.second).of(timestamp)
    end
  end

  describe "after running validation" do
    subject { site }

    let(:site) { build(:site, provider:, code: nil) }
    let(:provider) { build(:provider) }

    it "is assigned a valid code by default" do
      expect { subject.valid? }.to change { subject.code.blank? }.from(true).to(false)
      expect(subject.errors[:code]).to be_empty
    end
  end

  its(:recruitment_cycle) { is_expected.to eq find(:recruitment_cycle) }

  describe "description" do
    subject { build(:site, location_name: "Foo", code: "1") }

    its(:to_s) { is_expected.to eq "Foo (code: 1)" }
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
            address1: "5",
            address2: "Long Lane",
            address3: "Holbury",
            town: "Southampton",
            address4: nil,
            postcode: "SO45 2PA")
    end

    describe "#full_address" do
      context "location name is not 'Main site'" do
        it "includes location name in full address" do
          expect(site.full_address).to eq("Southampton High School, 5, Long Lane, Holbury, Southampton, SO45 2PA")
        end
      end

      context "location name is 'Main site'" do
        before do
          site.location_name = "Main site"
        end

        it "excludes location name in full address" do
          expect(site.full_address).to eq("5, Long Lane, Holbury, Southampton, SO45 2PA")
        end
      end

      context "address is missing" do
        before do
          site.location_name = ""
          site.address1 = ""
          site.address2 = ""
          site.address3 = ""
          site.town = ""
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

          site.save

          expect(GeocodeJob).not_to have_received(:perform_later)
        end
      end

      context "skip_geocoding is 'false'" do
        it "does not geocode" do
          site.skip_geocoding = false

          site.save

          expect(GeocodeJob).to have_received(:perform_later)
        end
      end
    end

    describe "#needs_geolocation?" do
      subject { site.needs_geolocation? }

      context "latitude is nil" do
        let(:site) { build_stubbed(:site, latitude: nil) }

        it { is_expected.to be(true) }
      end

      context "longitude is nil" do
        let(:site) { build_stubbed(:site, longitude: nil) }

        it { is_expected.to be(true) }
      end

      context "latitude and longitude is not nil" do
        let(:site) { build_stubbed(:site, latitude: 1.456789, longitude: 1.456789) }

        it { is_expected.to be(false) }
      end

      context "address" do
        let(:site) do
          create(:site,
                 latitude: 1.456789,
                 longitude: 1.456789,
                 location_name: "Southampton High School",
                 address1: "Long Lane",
                 address2: "Holbury",
                 town: "Southampton",
                 address4: nil,
                 postcode: "SO45 2PA")
        end

        context "has not changed" do
          before do
            site.update(address1: "Long Lane")
          end

          it { is_expected.to be(false) }
        end

        context "has changed" do
          before do
            site.update(address1: "New address 1")
          end

          it { is_expected.to be(true) }
        end
      end
    end
  end

  describe "added via" do
    it "defines a string enum for added_via" do
      expect(described_class.added_via).to eq({
        "publish_interface" => "publish_interface",
        "register_import" => "register_import",
      })
    end
  end

  describe "site type" do
    let(:site) { build(:site) }

    it { is_expected.to define_enum_for(:site_type).with_values(%i[school study_site]) }

    context "default" do
      it "is school" do
        expect(site.site_type).to eq("school")
      end
    end

    context "when site_type is a study site" do
      subject { site.site_type }

      before { site.study_site! }

      it { is_expected.to eq("study_site") }
    end
  end
end
