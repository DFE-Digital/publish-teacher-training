require "rails_helper"

describe "GET /provider-suggestions" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  it "searches for a particular provider for the user in the current recruitment cycle" do
    provider = create(:provider, provider_name: "PROVIDER 1")
    create(:provider, provider_name: "PROVIDER 2")

    get "/api/v3/provider-suggestions?query=#{provider.provider_name}"

    expect(JSON.parse(response.body)["data"]).to match_array([
      {
        "id" => provider.id.to_s,
        "type" => "providers",
        "attributes" => {
          "provider_code" => provider.provider_code,
          "provider_name" => provider.provider_name,
          "recruitment_cycle_year" => "2020",
        },
      },
    ])
  end

  it "searches for a provider that is not in the current recruitment cycle" do
    next_recruitment_cycle = find_or_create(:recruitment_cycle, :next)
    provider = create(:provider, recruitment_cycle: next_recruitment_cycle)

    get "/api/v3/provider-suggestions?query=#{provider.provider_name}"

    expect(JSON.parse(response.body)["data"]).to match_array([])
  end

  it "searches for a partial provider in the current recruitment cycle" do
    provider1 = create(:provider, provider_name: "PROVIDER 1")
    provider2 = create(:provider, provider_name: "PROVIDER 2")

    get "/api/v3/provider-suggestions?query=#{provider2.provider_name[0..3]}"

    expect(JSON.parse(response.body)["data"]).to match_array([
      {
        "id" => provider1.id.to_s,
        "type" => "providers",
        "attributes" => {
          "provider_code" => provider1.provider_code,
          "provider_name" => provider1.provider_name,
          "recruitment_cycle_year" => "2020",
        },
      },
      {
        "id" => provider2.id.to_s,
        "type" => "providers",
        "attributes" => {
          "provider_code" => provider2.provider_code,
          "provider_name" => provider2.provider_name,
          "recruitment_cycle_year" => "2020",
        },
      },
    ])
  end

  it "limits responses to a maximum of 10 items" do
    11.times do
      create(:provider, provider_name: "provider X")
    end

    get "/api/v3/provider-suggestions?query=provider"

    expect(JSON.parse(response.body)["data"].length).to eq(10)
  end

  it "returns bad request if query is empty" do
    get "/api/v3/provider-suggestions"

    expect(response.status).to eq(400)
  end

  it "returns bad request if query is too short" do
    provider = create(:provider, provider_name: "PROVIDER")

    get "/api/v3/provider-suggestions?query=#{provider.provider_name[0, 2]}"

    expect(response.status).to eq(400)
  end

  it "returns bad request if start of query is not alphanumeric" do
    get "/api/v3/provider-suggestions?query=%22%22%22%22"

    expect(response.status).to eq(400)
  end
end
