describe Geolocation do
  include ActiveJob::TestHelper

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  # Geocoding stubbed with support/helpers.rb
  let(:site) {
    build(:site,
          address1: "Long Lane",
          address2: "Holbury",
          address3: "Southampton",
          address4: nil,
          postcode: "SO45 2PA",
          provider: provider, code: nil)
  }

  let(:provider) { build(:provider) }

  describe "#full_address" do
    it "Concatenates address details" do
      expect(site.full_address).to eq("Long Lane, Holbury, Southampton, SO45 2PA")
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

    context "address has not changed" do
      let(:site) {
        build_stubbed(:site,
                      latitude: 1.456789,
                      longitude: 1.456789,
                      address1: "Long Lane",
                      address2: "Holbury",
                      address3: "Southampton",
                      address4: nil,
                      postcode: "SO45 2PA")
      }

      before do
        site.assign_attributes(address1: "Long Lane")
      end

      it { should be(false) }
    end

    context "address not changed" do
      let(:site) {
        build_stubbed(:site,
                      latitude: 1.456789,
                      longitude: 1.456789,
                      address1: "Long Lane",
                      address2: "Holbury",
                      address3: "Southampton",
                      address4: nil,
                      postcode: "SO45 2PA")
      }

      before do
        site.assign_attributes(address1: "New address 1")
      end

      it { should be(true) }
    end
  end
end
