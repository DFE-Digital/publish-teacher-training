require "rails_helper"

describe 'PATCH recruitment_cycles/year/providers/:provider_code/courses/:course_code' do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:request_path) do
    "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" +
      "/providers/#{provider.provider_code}"
  end

  def perform_request(updated_provider_ucas_preferences)
    jsonapi_data = jsonapi_renderer.render(
      provider,
      class: {
        Provider: API::V2::SerializableProvider
      }
    )

    jsonapi_data[:data][:attributes] = updated_provider_ucas_preferences

    patch request_path,
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: {
            _jsonapi: jsonapi_data
          }
  end

  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:organisation) { create :organisation }
  let(:provider)     do
    create :provider,
           organisations: [organisation],
           recruitment_cycle: recruitment_cycle,
           ucas_preferences: ucas_preferences
  end
  let(:user)         { create :user, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
  let(:ucas_preferences) { build(:provider_ucas_preference, type_of_gt12: :no_response, send_application_alerts: :all) }


  let(:updated_provider_ucas_preferences) do
    {
      type_of_gt12: 'coming_or_not',
      gt12_contact: 'test@mail.com',
      application_alert_contact: 'application_alert@mail.com',
      send_application_alerts: 'none'
    }
  end

  before do
    perform_request(updated_provider_ucas_preferences)
  end

  context "provider has updated provider ucas_preferences" do
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    subject { provider.ucas_preferences.reload }

    describe 'type_of_gt12' do
      its(:type_of_gt12) { should eq updated_provider_ucas_preferences[:type_of_gt12] }
      its(:gt12_response_destination) { should eq updated_provider_ucas_preferences[:gt12_contact] }
      its(:application_alert_email) { should eq updated_provider_ucas_preferences[:application_alert_contact] }
      its(:send_application_alerts) { should eq updated_provider_ucas_preferences[:send_application_alerts] }
    end
  end
end
