require "rails_helper"

describe "GET /provider-suggestions" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:organisation) { create(:organisation) }
  let(:provider1) { create(:provider, provider_name: "PROVIDER 1", organisations: [organisation]) }
  let(:provider2) { create(:provider, provider_name: "PROVIDER 2", organisations: [organisation]) }
  let(:next_recruitment_cycle) { find_or_create(:recruitment_cycle, :next) }
  let(:provider3) { create(:provider, provider_name: provider2.provider_name, organisations: [organisation], recruitment_cycle: next_recruitment_cycle) }
  let(:provider4) { create(:provider, organisations: [organisation], recruitment_cycle: next_recruitment_cycle) }

  before do
    provider1
    provider2
    provider3
    provider4
  end

  it "searches for a particular provider for the user in the current recruitment cycle" do
    get "/api/v3/provider-suggestions?query=#{provider2.provider_name}"

    expect(JSON.parse(response.body)["data"]).to match_array([
      {
        "id" => provider2.id.to_s,
        "type" => "provider",
        "attributes" => {
          "provider_code" => provider2.provider_code,
          "provider_name" => provider2.provider_name,
        },
      },
    ])
  end

  it "searches for a provider that is not in the current recruitment cycle" do
    get "/api/v3/provider-suggestions?query=#{provider4.provider_name}"

    expect(JSON.parse(response.body)["data"]).to match_array([])
  end

  it "searches for a partial provider in the current recruitment cycle" do
    get "/api/v3/provider-suggestions?query=#{provider2.provider_name[0..3]}"

    expect(JSON.parse(response.body)["data"]).to match_array([
      {
        "id" => provider1.id.to_s,
        "type" => "provider",
        "attributes" => {
          "provider_code" => provider1.provider_code,
          "provider_name" => provider1.provider_name,
        },
      },
      {
        "id" => provider2.id.to_s,
        "type" => "provider",
        "attributes" => {
          "provider_code" => provider2.provider_code,
          "provider_name" => provider2.provider_name,
        },
      },
    ])
  end

  it "limits responses to a maximum of 5 items" do
    20.times do
      create(:provider, provider_name: "provider X", organisations: [organisation])
    end

    get "/api/v3/provider-suggestions?query=provider"

    expect(JSON.parse(response.body)["data"].length).to eq(5)
  end

  it "returns bad request if query is empty" do
    get "/api/v3/provider-suggestions"

    expect(response.status).to eq(400)
  end

  it "returns bad request if query is too short" do
    get "/api/v3/provider-suggestions?query=#{provider2.provider_name[0, 2]}"

    expect(response.status).to eq(400)
  end

  it "returns bad request if start of query is not alphanumeric" do
    get "/api/v3/provider-suggestions?query=%22%22%22%22"

    expect(response.status).to eq(400)
  end
end
