require "rails_helper"

describe TravelToWorkAreaAndLondonBoroughService do
  describe "#add_travel_to_work_area_and_london_borough" do
    let(:valid_site) {
      create(:site,
             location_name: "School of DfE",
             address1: "28 Great Smith Street",
             address2: "Londo",
             address3: "",
             address4: "UK",
             postcode: "SW1P 3BT",
             latitude: 51.498160,
             longitude: -0.129900)
    }

    let(:invalid_site) do
      build(:site, latitude: "this is not a latitude")
    end

    let(:valid_site_mapit_endpoint) do
      URI("https://mapit.mysociety.org/point/4326/#{valid_site.longitude},#{valid_site.latitude}?type=TTW,LBO&api_key=#{Settings.mapit_api_key}")
    end

    let(:invalid_mapit_endpoint) do
      URI("https://mapit.mysociety.org/point/4326/#{invalid_site.longitude},#{invalid_site.latitude}?type=TTW,LBO&api_key=#{Settings.mapit_api_key}")
    end

    let(:valid_response) do
      "{
      \"163653\":
        {
          \"parent_area\": null,
          \"generation_high\": 41,
          \"all_names\": {},
          \"id\": 163653,
          \"codes\": {\"gss\": \"E30000234\"},
          \"name\": \"London\",
          \"country\": \"E\",
          \"type_name\": \"Travel to Work Areas\",
          \"generation_low\": 38,
          \"country_name\": \"England\",
          \"type\": \"TTW\"
        },
      \"2504\":
      {
        \"parent_area\": null,
        \"generation_high\": 41,
        \"all_names\": {},
        \"id\": 2504,
        \"codes\": {\"unit_id\": \"11164\", \"ons\": \"00BK\", \"gss\": \"E09000033\", \"local-authority-eng\": \"WSM\", \"local-authority-canonical\": \"WSM\"},
        \"name\": \"Westminster City Council\",
        \"country\": \"E\",
        \"type_name\": \"London borough\",
        \"generation_low\": 1,
        \"country_name\": \"England\",
        \"type\": \"LBO\"
        }
      }"
    end

    let(:invalid_response) do
      "<!DOCTYPE HTML>\n
      <html lang=\"en-gb\">
      </html>"
    end

    context "a valid site" do
      before { stub_request(:get, valid_site_mapit_endpoint).to_return(body: valid_response) }

      it "updates the travel to work area and london borough" do
        expect { described_class.add_travel_to_work_area_and_london_borough(site: valid_site) }.
          to change { valid_site.reload.travel_to_work_area }.from(nil).to("London").
            and change { valid_site.london_borough }.from(nil).to("Westminster City Council")
      end
    end

    context "invalid site" do
      before { stub_request(:get, invalid_mapit_endpoint).to_return(body: invalid_response) }

      it "throws an error" do
        expect { described_class.add_travel_to_work_area_and_london_borough(site: invalid_site) }.
          to raise_error(JSON::ParserError)
      end
    end
  end
end
