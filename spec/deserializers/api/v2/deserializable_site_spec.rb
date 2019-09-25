describe API::V2::DeserializableSite do
  let(:site) { build(:site) }
  let(:site_jsonapi) do
    JSON.parse(jsonapi_renderer.render(
      site,
      class: {
        Site: API::V2::SerializableSite,
      },
    ).to_json)["data"]
  end
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  subject { described_class.new(site_jsonapi).to_h }

  describe "attributes" do
    it { should include(address1: site.address1) }
    it { should include(address2: site.address2) }
    it { should include(address3: site.address3) }
    it { should include(address4: site.address4) }
    it { should include(code: site.code) }
    it { should include(location_name: site.location_name) }
    it { should include(postcode: site.postcode) }
    it { should include(region_code: site.region_code) }
  end
end
