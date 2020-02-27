describe GeocoderService do
  describe "#geocode" do
    let(:valid_site) { create(:site, region_code: nil) }

    let(:invalid_site) do
      invalid_site = build(:site, postcode: "this is not a postcode", region_code: nil)
      invalid_site.save!(validate: false)
      invalid_site
    end

    it "geocodes a valid object" do
      expect { GeocoderService.geocode(obj: valid_site) }.
          to change { valid_site.reload.latitude }.from(nil).to(51.4524877).
              and change { valid_site.longitude }.from(nil).to(-0.1204749).
              and change { valid_site.region_code }.from(nil).to("london")
    end

    it "does not geocode an invalid object by default" do
      expect { GeocoderService.geocode(obj: invalid_site) }.
          to raise_error(ActiveRecord::RecordInvalid)
    end

    it "geocodes an invalid object if forced" do
      expect { GeocoderService.geocode(obj: invalid_site, force: true) }.
          to change { invalid_site.reload.latitude }.from(nil).to(51.4524877).
              and change { invalid_site.longitude }.from(nil).to(-0.1204749).
              and change { invalid_site.region_code }.from(nil).to("london")
    end

    it "geocodes UK (gb) addresses only" do
      expect(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).with(valid_site.full_address, bias: "gb")

      GeocoderService.geocode(obj: valid_site)
    end
  end
end
