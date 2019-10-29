require "rails_helper"

describe "PATCH recruitment_cycles/year/providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:request_path) do
    "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" +
      "/providers/#{provider.provider_code}"
  end

  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:organisation) { create :organisation }
  let(:user)         { create :user, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
  let(:ucas_preferences) { build(:provider_ucas_preference, type_of_gt12: :no_response, send_application_alerts: :all) }

  let(:updated_provider_ucas_preferences) do
    {
      type_of_gt12: "coming_or_not",
      gt12_contact: "test@mail.com",
      application_alert_contact: "application_alert@mail.com",
      send_application_alerts: "none",
    }
  end

  before do
    perform_request(updated_provider_ucas_preferences)
  end

  subject { provider.ucas_preferences.reload }

  context "for a provider with existing preferences" do
    let(:provider) do
      create :provider,
             organisations: [organisation],
             recruitment_cycle: recruitment_cycle,
             ucas_preferences: ucas_preferences
    end

    it "is successful" do
      expect(response).to have_http_status(:success)
      check_attributes_assigned
    end
  end

  context "for a provider without existing preferences" do
    let(:provider) do
      create :provider,
             organisations: [organisation],
             recruitment_cycle: recruitment_cycle,
             ucas_preferences: nil
    end

    it "is successful" do
      expect(response).to have_http_status(:success)
      check_attributes_assigned
    end
  end
end

def perform_request(updated_provider_ucas_preferences)
  jsonapi_data = jsonapi_renderer.render(
    provider,
    class: {
      Provider: API::V2::SerializableProvider,
    },
    )

  jsonapi_data[:data][:attributes] = updated_provider_ucas_preferences

  patch request_path,
        headers: { "HTTP_AUTHORIZATION" => credentials },
        params: {
          _jsonapi: jsonapi_data,
        }
end

def check_attributes_assigned
  expect(subject.type_of_gt12).to eq updated_provider_ucas_preferences[:type_of_gt12]
  expect(subject.gt12_response_destination).to eq updated_provider_ucas_preferences[:gt12_contact]
  expect(subject.application_alert_email).to eq updated_provider_ucas_preferences[:application_alert_contact]
  expect(subject.send_application_alerts).to eq updated_provider_ucas_preferences[:send_application_alerts]
end
