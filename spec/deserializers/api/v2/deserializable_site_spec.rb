require "rails_helper"

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
    it { is_expected.to include(address1: site.address1) }
    it { is_expected.to include(address2: site.address2) }
    it { is_expected.to include(address3: site.address3) }
    it { is_expected.to include(address4: site.address4) }
    it { is_expected.to include(code: site.code) }
    it { is_expected.to include(location_name: site.location_name) }
    it { is_expected.to include(postcode: site.postcode) }
    it { is_expected.to include(region_code: site.region_code) }
  end
end
