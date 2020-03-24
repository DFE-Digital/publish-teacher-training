describe GeocoderService do
  describe "#geocode" do
    let(:valid_site) {
      create(:site,
             location_name: "Fun Academy",
                 address1: "Long Lane",
                 address2: "Holbury",
                 address3: "Southampton",
                 address4: "UK",
                 postcode: "SO45 2PA",
                 region_code: nil)
    }

    let(:invalid_site) do
      invalid_site = build(:site, postcode: "this is not a postcode", region_code: nil)
      invalid_site.save!(validate: false)
      invalid_site
    end

    let(:site_with_no_address) do
      site = build(:site,
                   location_name: "",
                   address1: "",
                   address2: "",
                   address3: "",
                   address4: "",
                   postcode: "",
                   region_code: nil)
      site.save!(validate: false)
      site
    end

    context "a valid object" do
      it "geocodes a valid object" do
        expect { GeocoderService.geocode(obj: valid_site) }.
          to change { valid_site.reload.latitude }.from(nil).to(50.8312522).
            and change { valid_site.longitude }.from(nil).to(-1.3792036).
            and change { valid_site.region_code }.from(nil).to("south_east")
      end

      it "geocodes UK (gb) addresses only" do
        expect(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).with(valid_site.full_address, bias: "gb")

        GeocoderService.geocode(obj: valid_site)
      end
    end

    context "invalid object" do
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

      it "does not save to database if Geocoder returns an unsuccessful response" do
        expect { GeocoderService.geocode(obj: site_with_no_address, force: true) }.
          to not_change { site_with_no_address.latitude }.
            and(not_change { site_with_no_address.longitude }).
            and(not_change { site_with_no_address.region_code })
      end
    end
  end
end
