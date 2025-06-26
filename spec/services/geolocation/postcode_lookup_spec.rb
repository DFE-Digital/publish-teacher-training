require "rails_helper"

RSpec.describe Geolocation::PostcodeLookup do
  subject(:postcode_lookup) { described_class.new(latitude: latitude, longitude: longitude, client: client) }

  let(:latitude) { 51.5074 }
  let(:longitude) { -0.1278 }
  let(:client) { instance_double(GoogleOldPlacesAPI::Client) }

  describe "#call" do
    context "when the API returns a valid postcode" do
      before do
        allow(client).to receive(:reverse_geocode).with(latitude: latitude, longitude: longitude).and_return(
          { postcode: "SW1A 1AA" },
        )
      end

      it "returns the postcode" do
        result = postcode_lookup.call
        expect(result).to eq({ postcode: "SW1A 1AA" })
      end
    end
  end
end
