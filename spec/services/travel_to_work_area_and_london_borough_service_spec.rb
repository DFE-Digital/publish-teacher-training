require "rails_helper"

describe TravelToWorkAreaAndLondonBoroughService do
  describe "#add_travel_to_work_area_and_london_borough" do
    let(:travel_to_work_areas_query) do
      URI("#{Settings.mapit_url}/point/4326/#{site.longitude},#{site.latitude}?type=TTW&api_key=#{Settings.mapit_api_key}")
    end

    context "a site with known coordinates" do
      let(:site) {
        create(:site,
               location_name: "Cambridge School of DfE",
               address1: "28 Interesting Street",
               address2: "Cambridge",
               address3: "",
               address4: "UK",
               postcode: "CB5 3BT",
               latitude: 51.498160,
               longitude: -0.129900)
      }

      let(:london_boroughs_query) do
        URI("#{Settings.mapit_url}/point/4326/#{site.longitude},#{site.latitude}?type=LBO&api_key=#{Settings.mapit_api_key}")
      end

      let(:london_borough) { nil }

      let(:travel_to_work_areas_successful_response) do
        {
          "163653": {
            "parent_area": nil,
            "generation_high": 41,
            "all_names": {},
            "id": 163653,
            "codes": {
              "gss": "E30000234",
            },
            "name": travel_to_work_area,
            "country": "E",
            "type_name": "Travel to Work Areas",
            "generation_low": 38,
            "country_name": "England",
            "type": "TTW",
          },
        }.to_json
      end

      let(:london_boroughs_successful_response) do
        {
          "2504": {
            "parent_area": nil,
            "generation_high": 41,
            "all_names": {},
            "id": 2504,
            "codes": {
              "unit_id": "11164",
              "ons": "00BK",
              "gss": "E09000033",
              "local-authority-eng": "WSM",
              "local-authority-canonical": "WSM",
            },
            "name": london_borough,
            "country": "E",
            "type_name": "London borough",
            "generation_low": 1,
            "country_name": "England",
            "type": "LBO",
          },
        }.to_json
      end
      before do
        stub_request(:get, travel_to_work_areas_query).to_return(body: travel_to_work_areas_successful_response)
        stub_request(:get, london_boroughs_query).to_return(body: london_boroughs_successful_response)
      end

      context "when the travel to work area is not London" do
        let(:travel_to_work_area) { "Cambridge" }

        it "updates the travel to work area and london_borough remains nil" do
          expect { described_class.call(site: site) }.
            to change { site.reload.travel_to_work_area }.from(nil).to("Cambridge").
              and(not_change { site.london_borough })
        end
      end

      context "when the travel to work area is London" do
        let(:travel_to_work_area) { "London" }

        context "and the London Borough is 'Westminster City Council'" do
          let(:london_borough) { "Westminster City Council" }

          it "updates the london Borough to Westminster" do
            expect { described_class.call(site: site) }.
              to change { site.reload.travel_to_work_area }.from(nil).to("London").
                and change { site.london_borough }.from(nil).to("Westminster")
          end
        end

        context "and the London Borough is 'City of London Corporation'" do
          let(:london_borough) { "City of London Corporation" }

          it "updates the london Borough to City of London" do
            expect { described_class.call(site: site) }.
              to change { site.reload.travel_to_work_area }.from(nil).to("London").
                and change { site.london_borough }.from(nil).to("City of London")
          end
        end

        context "and the London Borough is includes 'Borough Council'" do
          let(:london_borough) { "Greenwich Borough Council" }

          it "updates removes 'London Borough' from the string" do
            expect { described_class.call(site: site) }.
              to change { site.reload.travel_to_work_area }.from(nil).to("London").
                and change { site.london_borough }.from(nil).to("Greenwich")
          end
        end
      end
    end

    context "a site with unknown coordinates" do
      let(:site) do
        build(:site, latitude: "unknown latitude", longitude: "unknown longitude")
      end

      before do
        stub_request(:get, travel_to_work_areas_query).to_return(status: 404)
      end

      it "returns false" do
        expect(described_class.call(site: site)).to eq false
      end
    end

    context "when the Mapit API call is not successful" do
      let(:site) do
        build_stubbed(:site)
      end

      before do
        stub_request(:get, travel_to_work_areas_query).to_return(status: 404)
      end

      it "generates an error that is captured by Sentry" do
        expect(Raven).to receive(:capture_message).with(
          "Mapit API has returned status code 404 for Site id #{site.id} whilst trying to obtain travel_to_work_area",
        )

        described_class.call(site: site)
      end
    end
  end
end
