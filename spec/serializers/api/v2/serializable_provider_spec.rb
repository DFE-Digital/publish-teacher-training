require "rails_helper"

describe API::V2::SerializableProvider do
  let(:ucas_preferences) { build(:provider_ucas_preference, type_of_gt12: :coming_or_not) }
  let(:accrediting_provider) { create(:provider, :accredited_body) }
  let(:course) { create(:course, accrediting_provider: accrediting_provider) }
  let(:user) { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:site) { create(:site) }
  let(:contact) { create(:contact) }
  let(:provider) do
    create :provider,
           ucas_preferences: ucas_preferences,
           courses: [course],
           contacts: [contact],
           sites: [site],
           organisations: [organisation]
  end
  let(:resource) { described_class.new object: provider }
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  it "sets type to providers" do
    expect(resource.jsonapi_type).to eq :providers
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { is_expected.to have_type "providers" }
  it { is_expected.to have_attribute(:provider_code).with_value(provider.provider_code) }
  it { is_expected.to have_attribute(:provider_name).with_value(provider.provider_name) }
  it { is_expected.to have_attribute(:accredited_body?).with_value(false) }
  it { is_expected.to have_attribute(:can_add_more_sites?).with_value(true) }
  it { is_expected.to have_attribute(:recruitment_cycle_year).with_value(provider.recruitment_cycle.year) }
  it { is_expected.to have_attribute(:gt12_contact).with_value(provider.ucas_preferences.gt12_response_destination) }
  it { is_expected.to have_attribute(:application_alert_contact).with_value(provider.ucas_preferences.application_alert_email) }
  it { is_expected.to have_attribute(:type_of_gt12).with_value(provider.ucas_preferences.type_of_gt12) }
  it { is_expected.to have_attribute(:send_application_alerts).with_value(provider.ucas_preferences.send_application_alerts) }
  it { is_expected.to have_attribute(:train_with_us).with_value(provider.train_with_us) }
  it { is_expected.to have_attribute(:train_with_disability).with_value(provider.train_with_disability) }
  it { is_expected.to have_attribute(:can_sponsor_student_visa).with_value(provider.can_sponsor_student_visa) }
  it { is_expected.to have_attribute(:can_sponsor_skilled_worker_visa).with_value(provider.can_sponsor_skilled_worker_visa) }

  it do
    expect(subject).to have_attribute(:accredited_bodies).with_value([
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
          User: API::V2::SerializableUser,
          Provider: API::V2::SerializableProvider,
          Site: API::V2::SerializableSite,
          Contact: API::V2::SerializableContact,
        },
        include: %i[
          users sites contacts
        ],
      )
    end

    it "includes the users relationship" do
      expect(subject.dig(:data, :relationships, :users, :data).count).to eq(1)
      expect(subject.dig(:data, :relationships, :users, :data).first).to eq({ type: :users, id: user.id.to_s })
    end

    it "includes the sites relationship" do
      expect(subject.dig(:data, :relationships, :sites, :data).count).to eq(1)
      expect(subject.dig(:data, :relationships, :sites, :data).first).to eq({ type: :sites, id: site.id.to_s })
    end

    it "includes the contacts relationship" do
      expect(subject.dig(:data, :relationships, :contacts, :data).count).to eq(1)
      expect(subject.dig(:data, :relationships, :contacts, :data).first).to eq({ type: :contacts, id: contact.id.to_s })
    end
  end
end
