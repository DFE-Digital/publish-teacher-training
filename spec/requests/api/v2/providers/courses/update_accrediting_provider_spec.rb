require "rails_helper"

describe 'PATCH /providers/:provider_code/courses/:course_code' do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_accrediting_provider_code)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse
      }
    )

    jsonapi_data[:data][:attributes] = updated_accrediting_provider_code

    patch "/api/v2/providers/#{course.provider.provider_code}" \
            "/courses/#{course.course_code}",
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: {
            _jsonapi: jsonapi_data
          }
  end
  let(:organisation)      { create :organisation }
  let(:provider)          { create :provider, organisations: [organisation] }
  let(:user)              { create :user, organisations: [organisation] }
  let(:payload)           { { email: user.email } }
  let(:token)             { build_jwt :apiv2, payload: payload }

  let(:course)            { create :course, provider: provider }

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  before do
    perform_request(accrediting_provider_code)
  end

  context "course has an updated accrediting_provider_code attribute" do
    let(:accrediting_provider_code) { { accrediting_provider_code: '1AA' } }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the `accrediting_provider_code` attribute to the correct value" do
      expect(course.reload.accrediting_provider_code).to eq(accrediting_provider_code[:accrediting_provider_code])
    end
  end

  context "course has the same accrediting_provider_code value" do
    context "with values passed into the params" do
      let(:accrediting_provider_code) { { accrediting_provider_code: '1AA' } }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "does not change `accrediting_provider_code` attribute" do
        expect(course.reload.accrediting_provider_code).to eq(accrediting_provider_code[:accrediting_provider_code])
      end
    end
  end

  context "with no values passed into the params" do
    let(:accrediting_provider_code) { {} }

    before do
      @accrediting_provider_code = course.accrediting_provider_code
      perform_request(accrediting_provider_code)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "does not change `accrediting_provider_code` attribute" do
      expect(course.reload.accrediting_provider_code).to eq(@accrediting_provider_code)
    end
  end
end
