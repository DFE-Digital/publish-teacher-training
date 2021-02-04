require "mcb_helper"

describe "mcb add_ttwa_or_london_borough" do
  def execute_cmd(input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(["sites", "add_ttwa_or_london_borough", "-b", "-s"])
    end
  end

  let(:email) { "user@education.gov.uk" }
  let(:current_cycle) { find_or_create :recruitment_cycle }
  let(:organisation) { create(:organisation) }
  let(:provider) { create :provider, recruitment_cycle: current_cycle }
  let(:site1) { create(:site, provider: provider, latitude: 1.23, longitude: 4.56) }
  let(:site2) { create(:site, provider: provider, latitude: 7.89, longitude: 0.00) }
  let(:previous_cycle) { find_or_create :recruitment_cycle, :previous }
  let(:previous_cycles_provider) { create :provider, recruitment_cycle: previous_cycle }
  let(:site3) { create(:site, provider: provider, latitude: 7.89, longitude: 0.00) }
  let!(:requester) { create(:user, email: email, organisations: [organisation]) }

  let(:default_sleep) { 0.25 }
  let(:default_batch_size) { 100 }


  let(:first_response) do
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

  let(:second_response) do
    "{
      \"163692\":
        {
          \"parent_area\": null,
          \"generation_high\": 41,
          \"all_names\": {},
          \"id\": 163692,
          \"codes\": {\"gss\": \"E30000273\"},
          \"name\": \"Stoke-on-Trent\",
          \"country\": \"E\",
          \"type_name\": \"Travel to Work Areas\",
          \"generation_low\": 38,
          \"country_name\": \"England\",
          \"type\": \"TTW\"
        }
      }"
  end

  let(:site1_mapit_endpoint) do
    URI("https://mapit.mysociety.org/point/4326/#{site1.longitude},#{site1.latitude}?type=TTW,LBO&api_key=#{Settings.mapit_api_key}")
  end

  let(:site2_mapit_endpoint) do
    URI("https://mapit.mysociety.org/point/4326/#{site2.longitude},#{site2.latitude}?type=TTW,LBO&api_key=#{Settings.mapit_api_key}")
  end

  before do
    allow(MCB).to receive(:init_rails)
    stub_request(:get, site1_mapit_endpoint).to_return(body: first_response)
    stub_request(:get, site2_mapit_endpoint).to_return(body: second_response)
  end

  it "Populates travel_to_work_area_or_london_borough for all sites" do
    expect { execute_cmd }
      .to change { site1.reload.london_borough }.from(nil).to("Westminster City Council")
            .and change { site1.reload.travel_to_work_area }.from(nil).to("London")
              .and change { site2.reload.travel_to_work_area  }.from(nil).to("Stoke-on-Trent")
                .and(not_change { site2.reload.london_borough })
                  .and(not_change { site3.reload.travel_to_work_area })
                    .and(not_change { site3.reload.london_borough })

    expect(MCB).to have_received(:run_command).with("sites add_ttwa_or_london_borough -b -s")
  end
end
