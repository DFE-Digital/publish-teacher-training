# frozen_string_literal: true

require "rails_helper"

RSpec.describe FindAndUseAnAPI::Client do
  let(:client) { described_class.new(base_url: "https://fauapi.example.com", api_key: "automation-token") }

  it "authenticates with the automation token" do
    stub_request(:get, "https://fauapi.example.com/api/tasks/apis")
      .with(headers: { "Authorization" => "Bearer automation-token" })
      .to_return(status: 200, body: [{ id: 178 }].to_json, headers: { "Content-Type" => "application/json" })

    expect(client.list_apis).to eq([{ "id" => 178 }])
  end

  it "raises with the portal's reasons when it rejects a request" do
    stub_request(:post, "https://fauapi.example.com/api/tasks/apis/import")
      .to_return(
        status: 400,
        body: { hasErrors: true, errors: ["The Environments field is required."] }.to_json,
        headers: { "Content-Type" => "application/json" },
      )

    expect { client.import({}) }
      .to raise_error(described_class::Rejected, /400.*The Environments field is required\./)
  end
end
