require "rails_helper"

describe API::V3::SerializableProvider do
  let(:accrediting_provider) { create(:provider, :accredited_body) }
  let(:course) { create(:course, accrediting_provider: accrediting_provider) }
  let(:site) { create(:site) }
  let(:provider) do
    create :provider,
           courses: [course],
           sites: [site]
  end

  let(:resource) { described_class.new object: provider }
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  it "sets type to providers" do
    expect(resource.jsonapi_type).to eq :providers
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type "providers" }
  it { should have_attribute(:provider_code).with_value(provider.provider_code) }
  it { should have_attribute(:provider_name).with_value(provider.provider_name) }
  it { should have_attribute(:provider_type).with_value(provider.provider_type) }
  it { should have_attribute(:address1).with_value(provider.address1) }
  it { should have_attribute(:address2).with_value(provider.address2) }
  it { should have_attribute(:address3).with_value(provider.address3) }
  it { should have_attribute(:address4).with_value(provider.address4) }
  it { should have_attribute(:postcode).with_value(provider.postcode) }
  it { should have_attribute(:region_code).with_value(provider.region_code) }
  it { should have_attribute(:email).with_value(provider.email) }
  it { should have_attribute(:website).with_value(provider.website) }
  it { should have_attribute(:telephone).with_value(provider.telephone) }
  it { should have_attribute(:accredited_body?).with_value(false) }
  it { should have_attribute(:recruitment_cycle_year).with_value(provider.recruitment_cycle.year) }
  it { should have_attribute(:train_with_us).with_value(provider.train_with_us) }
  it { should have_attribute(:train_with_disability).with_value(provider.train_with_disability) }
  it { should have_attribute(:latitude).with_value(provider.latitude) }
  it { should have_attribute(:longitude).with_value(provider.longitude) }

  it do
    should have_attribute(:accredited_bodies).with_value([
      {
        "provider_name" => accrediting_provider.provider_name,
        "provider_code" => accrediting_provider.provider_code,
        "description" => "",
      },
    ])
  end

  describe "includes" do
    subject do
      jsonapi_renderer.render(
        provider,
        class: {
          Provider: API::V3::SerializableProvider,
          Site: API::V2::SerializableSite,
        },
        include: %i[sites],
      )
    end

    it "includes the sites relationship" do
      expect(subject.dig(:data, :relationships, :sites, :data).count).to eq(1)
      expect(subject.dig(:data, :relationships, :sites, :data).first).to eq({ type: :sites, id: site.id.to_s })
    end
  end
end
