require "rails_helper"

describe "Accredited Provider API v2", type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
  let(:organisation) { create(:organisation, users: [user]) }
  let(:provider)       { create :provider, :accredited_body, organisations: [organisation] }
  let(:course) { findable_course }
  let!(:findable_course) do
    create :course, name: "findable-course",
           accrediting_provider: provider,
           site_statuses: [build(:site_status, :findable)]
  end
  let(:jsonapi_response) { JSON.parse(response.body) }
  let(:jsonapi_courses) {
    JSON.parse(
      JSONAPI::Serializable::Renderer.new.render(
        [course],
        class: {
          Course: API::V2::SerializableCourse,
        },
        ).to_json,
      )
  }

  describe "GET index" do
    before do
      path = "/api/v2/providers/#{provider.provider_code}" +
        "/accredited_body/courses"
      get path, headers: { "HTTP_AUTHORIZATION" => credentials }
    end

    it "returns the array of courses for which the provider is the accredited body" do
      expect(response).to have_http_status(:success)
      expect(jsonapi_response["data"]).to eq jsonapi_courses["data"]
    end
  end
end
