require "mcb_helper"

describe "mcb add_travel_to_work_data" do
  def execute_cmd(input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(%w[sites add_travel_to_work_data])
    end
  end

  let(:email) { "user@education.gov.uk" }
  let(:organisation) { create(:organisation) }
  let(:site1) { create(:site, latitude: 1.23, longitude: 4.56) }
  let(:site2) { create(:site, latitude: 7.89, longitude: 0.00) }
  let(:site3) { create(:site, latitude: 7.89, longitude: 0.00) }
  let!(:requester) { create(:user, email: email, organisations: [organisation]) }

  let(:first_travel_to_work_area_response) do
    {
      "163653": {
        parent_area: nil,
        generation_high: 41,
        all_names: {},
        id: 163653,
        codes: {
          gss: "E30000234",
        },
        name: "London",
        country: "E",
        type_name: "Travel to Work Areas",
        generation_low: 38,
        country_name: "England",
        type: "TTW",
      },
    }.to_json
  end

  let(:first_travel_to_work_london_borough_response) do
    {
      "2504": {
        parent_area: nil,
        generation_high: 41,
        all_names: {},
        id: 2504,
        codes: {
          unit_id: "11164",
          ons: "00BK",
          gss: "E09000033",
          "local-authority-eng": "WSM",
          "local-authority-canonical": "WSM",
        },
        name: "Westminster City Council",
        country: "E",
        type_name: "London borough",
        generation_low: 1,
        country_name: "England",
        type: "LBO",
      },
    }.to_json
  end

  let(:site1_travel_to_work_query) do
    URI("https://mapit.mysociety.org/point/4326/#{site1.longitude},#{site1.latitude}?type=TTW&api_key=#{Settings.mapit_api_key}")
  end

  let(:site1_london_borough_query) do
    URI("https://mapit.mysociety.org/point/4326/#{site1.longitude},#{site1.latitude}?type=LBO&api_key=#{Settings.mapit_api_key}")
  end

  before do
    allow(MCB).to receive(:init_rails)
    stub_request(:get, site1_travel_to_work_query).to_return(body: first_travel_to_work_area_response)
    stub_request(:get, site1_london_borough_query).to_return(body: first_travel_to_work_london_borough_response)
  end

  it "Populates travel_to_work_area and london_borough for a site" do
    expect { execute_cmd }
      .to change { site1.reload.london_borough }
        .from(nil)
        .to("Westminster")
        .and change { site1.reload.travel_to_work_area }
          .from(nil)
          .to("London")
  end
end
