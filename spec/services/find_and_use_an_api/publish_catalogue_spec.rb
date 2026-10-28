# frozen_string_literal: true

require "rails_helper"

RSpec.describe FindAndUseAnAPI::PublishCatalogue do
  let(:portal) { Settings.fauapi.base_url }
  let(:manifest) { JSON.parse(Rails.root.join("config/fauapi/manifest.json").read) }
  let(:api_spec) { Rails.root.join("swagger/public_v1/api_spec.json").read }
  let(:entries) { [{ id: 178, name: "teacher-training-courses-api", majorVersion: "v1" }] }

  before do
    stub_request(:post, "#{portal}/api/tasks/apis/import").to_return(status: 201)
    stub_request(:get, "#{portal}/api/tasks/apis")
      .to_return(status: 200, body: entries.to_json, headers: { "Content-Type" => "application/json" })
    stub_request(:put, %r{#{portal}/api/tasks/apis/\d+/publish}).to_return(status: 200)
  end

  it "imports the manifest with the public API spec inline" do
    described_class.call

    expect(a_request(:post, "#{portal}/api/tasks/apis/import").with do |request|
      JSON.parse(request.body) == manifest.merge(
        "schema" => {
          "fileName" => "api_spec.json",
          "name" => "api_spec.json",
          "schemaType" => "openapi",
          "contentType" => "application/json",
          "documentContentValue" => Base64.strict_encode64(api_spec),
        },
      )
    end).to have_been_made
  end

  context "when the portal holds other APIs and other major versions" do
    let(:entries) do
      [
        { id: 12, name: "registertraineeteachers", majorVersion: "v1" },
        { id: 177, name: "teacher-training-courses-api", majorVersion: "v2" },
        { id: 178, name: "teacher-training-courses-api", majorVersion: "v1" },
      ]
    end

    it "publishes only the entry the import updated" do
      described_class.call

      expect(a_request(:put, %r{/publish})).to have_been_made.once
      expect(a_request(:put, "#{portal}/api/tasks/apis/178/publish")).to have_been_made
    end
  end

  context "when the import left no matching entry" do
    let(:entries) { [] }

    it "raises without publishing" do
      expect { described_class.call }.to raise_error(described_class::Error, /no catalogue entry/i)
      expect(a_request(:put, %r{/publish})).not_to have_been_made
    end
  end

  context "when the import left several matching entries" do
    let(:entries) do
      [
        { id: 178, name: "teacher-training-courses-api", majorVersion: "v1" },
        { id: 201, name: "teacher-training-courses-api", majorVersion: "v1" },
      ]
    end

    it "raises without publishing" do
      expect { described_class.call }.to raise_error(described_class::Error, /178, 201/)
      expect(a_request(:put, %r{/publish})).not_to have_been_made
    end
  end
end
