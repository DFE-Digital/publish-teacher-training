require 'rails_helper'

describe API::V2::SerializableProvider do
  let(:ucas_preferences) { build(:provider_ucas_preference, type_of_gt12: :coming_or_not) }
  let(:accrediting_provider) { create(:provider, :accredited_body) }
  let(:course) { create(:course, accrediting_provider: accrediting_provider) }
  let(:provider) { create :provider, ucas_preferences: ucas_preferences, courses: [course], contacts: [contact1, contact2, contact3, contact4, contact5] }
  let(:resource) { described_class.new object: provider }
  let(:contact1)  { build(:contact, :admin_type) }
  let(:contact2)  { build(:contact, :utt_type) }
  let(:contact3)  { build(:contact, :web_link_type) }
  let(:contact4)  { build(:contact, :fraud_type) }
  let(:contact5)  { build(:contact, :finance_type) }


  it 'sets type to providers' do
    expect(resource.jsonapi_type).to eq :providers
  end

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it { should have_type 'providers' }
  it { should have_attribute(:provider_code).with_value(provider.provider_code) }
  it { should have_attribute(:provider_name).with_value(provider.provider_name) }
  it { should have_attribute(:accredited_body?).with_value(false) }
  it { should have_attribute(:can_add_more_sites?).with_value(true) }
  it { should have_attribute(:recruitment_cycle_year).with_value(provider.recruitment_cycle.year) }
  it { should have_attribute(:gt12_contact).with_value(provider.ucas_preferences.gt12_response_destination) }
  it { should have_attribute(:application_alert_contact).with_value(provider.ucas_preferences.application_alert_email) }
  it { should have_attribute(:type_of_gt12).with_value(provider.ucas_preferences.type_of_gt12) }

  it do
    should have_attribute(:accredited_bodies).with_value([
      {
        'provider_name' => accrediting_provider.provider_name,
        'provider_code' => accrediting_provider.provider_code,
        'description' => ''
      }
    ])
  end

  it {
    should have_attribute(:admin_contact).with_value(
      "name" => contact1.name,
      "email" => contact1.email,
      "telephone" => contact1.telephone
    )
  }

  it {
    should have_attribute(:utt_contact).with_value(
      "name" => contact2.name,
      "email" => contact2.email,
      "telephone" => contact2.telephone
    )
  }

  it {
    should have_attribute(:web_link_contact).with_value(
      "name" => contact3.name,
      "email" => contact3.email,
      "telephone" => contact3.telephone
    )
  }

  it {
    should have_attribute(:fraud_contact).with_value(
      "name" => contact4.name,
      "email" => contact4.email,
      "telephone" => contact4.telephone
    )
  }

  it {
    should have_attribute(:finance_contact).with_value(
      "name" => contact5.name,
      "email" => contact5.email,
      "telephone" => contact5.telephone
    )
  }
end
