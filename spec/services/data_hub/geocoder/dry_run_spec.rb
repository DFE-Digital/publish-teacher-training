# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::Geocoder::DryRun, type: :service do
  let(:geocoder) { described_class.new }
  let(:site) { create(:site, latitude: nil, longitude: nil) }

  describe "#geocode" do
    it "returns successful result with simulated UK coordinates" do
      result = geocoder.geocode(site)

      expect(result.success?).to be(true)
      expect(result.latitude).to be_between(49.9, 60.8)
      expect(result.longitude).to be_between(-8.6, 1.8)
      expect(result.error_message).to be_nil
    end

    it "does not modify the actual record" do
      expect { geocoder.geocode(site) }.not_to(change { site.reload.latitude })
    end

    it "simulates failure approximately 5% of the time" do
      results = 100.times.map { geocoder.geocode(site) }
      failures = results.count(&:failed?)

      # Should be around 5%, allow for randomness (0-15% range)
      expect(failures).to be_between(0, 15)
    end

    context "when simulating failure" do
      before do
        allow(geocoder).to receive(:rand).and_return(0.96) # > 0.95 triggers failure
      end

      it "returns failed result with error message" do
        result = geocoder.geocode(site)

        expect(result.success?).to be(false)
        expect(result.latitude).to be_nil
        expect(result.longitude).to be_nil
        expect(result.error_message).to eq("Simulated geocoding failure")
      end
    end

    it "generates different coordinates on each call" do
      result1 = geocoder.geocode(site)
      result2 = geocoder.geocode(site)

      expect(result1.latitude).not_to eq(result2.latitude)
      expect(result1.longitude).not_to eq(result2.longitude)
    end
  end

  describe "#dry_run?" do
    it "returns true for dry run geocoder" do
      expect(geocoder.dry_run?).to be(true)
    end
  end
end
