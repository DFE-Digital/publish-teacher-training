describe GeocoderService do
  describe "#geocode" do
    let(:valid_site) { create(:site) }

    let(:invalid_site) do
      invalid_site = build(:site, postcode: "this is not a postcode")
      invalid_site.save!(validate: false)
      invalid_site
    end

    it "geocodes a valid object" do
      expect { GeocoderService.geocode(obj: valid_site) }.
          to change { valid_site.reload.latitude }.from(nil).to(51.4524877).
              and change { valid_site.longitude }.from(nil).to(-0.1204749)
    end

    it "does not geocode an invalid object by default" do
      expect { GeocoderService.geocode(obj: invalid_site) }.
          to raise_error(ActiveRecord::RecordInvalid)
    end

    it "geocodes an invalid object if forced" do
      expect { GeocoderService.geocode(obj: invalid_site, force: true) }.
          to change { invalid_site.reload.latitude }.from(nil).to(51.4524877).
              and change { invalid_site.longitude }.from(nil).to(-0.1204749)
    end

    it "geocodes UK (gb) addresses only" do
      expect(Geocoder).to receive(:search).with(valid_site.full_address, params: { region: "gb" })

      GeocoderService.geocode(obj: valid_site)
    end
  end
end
