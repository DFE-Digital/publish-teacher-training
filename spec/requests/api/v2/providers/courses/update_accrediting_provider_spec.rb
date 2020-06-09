require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_accredited_body_code)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    jsonapi_data[:data][:attributes] = updated_accredited_body_code

    patch "/api/v2/providers/#{course.provider.provider_code}" \
            "/courses/#{course.course_code}",
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: {
            _jsonapi: jsonapi_data,
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
    perform_request(accredited_body_code: accredited_body_code)
  end

  context "course has an updated accredited_body_code attribute" do
    let(:accredited_body_code) { "1AA" }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the `accredited_body_code` attribute to the correct value" do
      expect(course.reload.accredited_body_code).to eq(accredited_body_code)
    end
  end

  context "course has the same accredited_body_code value" do
    context "with values passed into the params" do
      let(:accredited_body_code) { "1AA" }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "does not change `accredited_body_code` attribute" do
        expect(course.reload.accredited_body_code).to eq(accredited_body_code)
      end
    end
  end

  context "with no values passed into the params" do
    let(:accredited_body_code) {}

    before do
      @accredited_body_code = course.accredited_body_code
      perform_request(accredited_body_code: accredited_body_code)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "does not change `accredited_body_code` attribute" do
      expect(course.reload.accredited_body_code).to eq(@accredited_body_code)
    end
  end
end
