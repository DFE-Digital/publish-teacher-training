# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::Geocoder::DryRun, type: :service do
  let(:geocoder) { described_class.new }
  let(:site) { create(:site, latitude: nil, longitude: nil) }

  describe "#geocode" do
    context "when simulating success" do
      before do
        allow(geocoder).to receive(:rand).with(no_args).and_return(0.1)
        allow(geocoder).to receive(:rand).with(49.9..60.8).and_return(51.509865, 53.800755)
        allow(geocoder).to receive(:rand).with(-8.6..1.8).and_return(-0.118092, -1.549077)
      end

      it "returns successful result with simulated UK coordinates" do
        result = geocoder.geocode(site)

        expect(result.success?).to be(true)
        expect(result.latitude).to eq(51.509865)
        expect(result.longitude).to eq(-0.118092)
        expect(result.error_message).to be_nil
      end

      it "does not modify the actual record" do
        expect { geocoder.geocode(site) }.not_to(change { site.reload.latitude })
      end

      it "generates different coordinates on each call" do
        result1 = geocoder.geocode(site)
        result2 = geocoder.geocode(site)

        expect(result1.latitude).not_to eq(result2.latitude)
        expect(result1.longitude).not_to eq(result2.longitude)
      end
    end

    context "when simulating failure" do
      before do
        allow(geocoder).to receive(:rand).with(no_args).and_return(0.96)
      end

      it "returns failed result with error message" do
        result = geocoder.geocode(site)

        expect(result.success?).to be(false)
        expect(result.latitude).to be_nil
        expect(result.longitude).to be_nil
        expect(result.error_message).to eq("Simulated geocoding failure")
      end
    end

    context "success/failure ratio" do
      it "simulates failure approximately 5% of the time" do
        # 95 successes, 5 failures
        # Alternate the 'rand' value to control outcome: first 95 below 0.95 (success), last 5 above (failure)
        result_sequence = Array.new(95, 0.1) + Array.new(5, 0.96)
        allow(geocoder).to receive(:rand).with(no_args).and_return(*result_sequence)
        allow(geocoder).to receive(:rand).with(49.9..60.8).and_return(52.0)
        allow(geocoder).to receive(:rand).with(-8.6..1.8).and_return(-1.0)

        results = 100.times.map { geocoder.geocode(site) }
        failures = results.count(&:failed?)

        expect(failures).to eq(5)
      end
    end
  end

  describe "#dry_run?" do
    it "returns true for dry run geocoder" do
      expect(geocoder.dry_run?).to be(true)
    end
  end
end
