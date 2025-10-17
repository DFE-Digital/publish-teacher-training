# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::Geocoder::Real, type: :service do
  let(:geocoder) { described_class.new }
  let(:site) { create(:site, latitude: nil, longitude: nil, address1: "10 Downing Street", town: "London", postcode: "SW1A 2AA") }

  describe "#geocode" do
    context "when GeocoderService successfully geocodes" do
      before do
        allow(GeocoderService).to receive(:geocode).with(obj: site) do
          site.update!(latitude: 51.5034, longitude: -0.1276)
        end
      end

      it "returns successful result with coordinates" do
        result = geocoder.geocode(site)

        expect(result.success?).to be(true)
        expect(result.latitude).to eq(51.5034)
        expect(result.longitude).to eq(-0.1276)
        expect(result.error_message).to be_nil
      end
    end

    context "when GeocoderService fails to return coordinates" do
      before do
        allow(GeocoderService).to receive(:geocode).with(obj: site)
        # Coordinates remain nil
      end

      it "returns failed result with error message" do
        result = geocoder.geocode(site)

        expect(result.success?).to be(false)
        expect(result.latitude).to be_nil
        expect(result.longitude).to be_nil
        expect(result.error_message).to eq("Geocoding failed - no coordinates returned")
      end
    end

    context "when GeocoderService raises an error" do
      before do
        allow(GeocoderService).to receive(:geocode).with(obj: site).and_raise(StandardError, "API timeout")
      end

      it "catches error and returns failed result" do
        result = geocoder.geocode(site)

        expect(result.success?).to be(false)
        expect(result.latitude).to be_nil
        expect(result.longitude).to be_nil
        expect(result.error_message).to include("StandardError: API timeout")
      end
    end

    context "when record already has partial coordinates" do
      let(:site) { create(:site, latitude: 51.5, longitude: nil, address1: "Test St", town: "London", postcode: "SW1A 2AA") }

      before do
        allow(GeocoderService).to receive(:geocode).with(obj: site) do
          site.update!(latitude: 51.5034, longitude: -0.1276)
        end
      end

      it "updates to complete coordinates" do
        result = geocoder.geocode(site)

        expect(result.success?).to be(true)
        expect(result.latitude).to eq(51.5034)
        expect(result.longitude).to eq(-0.1276)
      end
    end
  end

  describe "#dry_run?" do
    it "returns false for real geocoder" do
      expect(geocoder.dry_run?).to be(false)
    end
  end
end
