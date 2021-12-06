require "rails_helper"

describe "PATCH recruitment_cycles/year/providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:organisation) { create :organisation }
  let(:provider)     do
    create :provider,
           organisations: [organisation],
           recruitment_cycle: recruitment_cycle,
           contacts: [build(:contact)]
  end
  let(:user)         { create :user, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:credentials) { encode_to_credentials(payload) }
  let(:admin_contact) { build(:contact, :admin_type) }
  let(:utt_contact) { build(:contact, :utt_type) }
  let(:web_link_contact) { build(:contact, :web_link_type) }
  let(:fraud_contact) { build(:contact, :fraud_type) }
  let(:finance_contact)  { build(:contact, :finance_type) }
  let(:updated_contacts) do
    {
      admin_contact: slice_contact(admin_contact),
      utt_contact: slice_contact(utt_contact),
      web_link_contact: slice_contact(web_link_contact),
      fraud_contact: slice_contact(fraud_contact),
      finance_contact: slice_contact(finance_contact),
    }
  end
  let(:request_path) do
    "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}"
  end

  def perform_request(updated_contacts)
    jsonapi_data = jsonapi_renderer.render(
      provider,
      class: {
        Provider: API::V2::SerializableProvider,
      },
    )

    jsonapi_data[:data][:attributes] = updated_contacts

    patch request_path,
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: {
            _jsonapi: jsonapi_data,
          }
  end

  def slice_contact(contact)
    contact.slice("name", "email", "telephone", "permission_given")
  end

  def find_contact(type)
    provider.reload.contacts.find_by(type: type)
  end

  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:provider) do
    create :provider,
           users: [user],
           recruitment_cycle: recruitment_cycle,
           contacts: [build(:contact)]
  end
  let(:user)         { create(:user) }
  let(:payload)      { { email: user.email } }
  let(:credentials) { encode_to_credentials(payload) }

  let(:admin_contact) { build(:contact, :admin_type) }
  let(:utt_contact) { build(:contact, :utt_type) }
  let(:web_link_contact) { build(:contact, :web_link_type) }
  let(:fraud_contact) { build(:contact, :fraud_type) }
  let(:finance_contact)  { build(:contact, :finance_type) }

  let(:updated_contacts) do
    {
      admin_contact: slice_contact(admin_contact),
      utt_contact: slice_contact(utt_contact),
      web_link_contact: slice_contact(web_link_contact),
      fraud_contact: slice_contact(fraud_contact),
      finance_contact: slice_contact(finance_contact),
    }
  end

  before do
    perform_request(updated_contacts)
  end

  context "provider has updated ucas contacts" do
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    subject { find_contact(type) }

    describe "admin contact" do
      let(:type) { "admin" }

      its(:name) { is_expected.to eq admin_contact.name }
      its(:email) { is_expected.to eq admin_contact.email }
      its(:telephone) { is_expected.to eq admin_contact.telephone }
    end

    describe "utt contact" do
      let(:type) { "utt" }

      its(:name) { is_expected.to eq utt_contact.name }
      its(:email) { is_expected.to eq utt_contact.email }
      its(:telephone) { is_expected.to eq utt_contact.telephone }
    end

    describe "web link contact" do
      let(:type) { "web_link" }

      its(:name) { is_expected.to eq web_link_contact.name }
      its(:email) { is_expected.to eq web_link_contact.email }
      its(:telephone) { is_expected.to eq web_link_contact.telephone }
    end

    describe "fraud contact" do
      let(:type) { "fraud" }

      its(:name) { is_expected.to eq fraud_contact.name }
      its(:email) { is_expected.to eq fraud_contact.email }
      its(:telephone) { is_expected.to eq fraud_contact.telephone }
    end

    describe "finance contact" do
      let(:type) { "finance" }

      its(:name) { is_expected.to eq finance_contact.name }
      its(:email) { is_expected.to eq finance_contact.email }
      its(:telephone) { is_expected.to eq finance_contact.telephone }
    end
  end
end
