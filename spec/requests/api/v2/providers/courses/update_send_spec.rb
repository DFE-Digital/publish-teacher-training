require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_is_send)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    jsonapi_data[:data][:attributes] = updated_is_send

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

  let(:course)            {
    create :course,
           provider: provider,
           subjects: [find_or_create(:primary_subject, :primary)],
           is_send: false
  }

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:permitted_params) do
    %i[updated_is_send]
  end

  before do
    perform_request(updated_is_send)
  end

  context "course has an updated is_send attribute" do
    let(:updated_is_send) { { is_send: true } }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the `is_send` attribute to the correct value" do
      expect(course.reload.is_send).to eq(updated_is_send[:is_send])
    end
  end

  context "course has the same SEND value" do
    context "with values passed into the params" do
      let(:updated_is_send) { { is_send: true } }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "does not change `is_send` attribute" do
        expect(course.reload.is_send).to eq(updated_is_send[:is_send])
      end
    end
  end

  context "with no values passed into the params" do
    let(:updated_is_send) { {} }

    before do
      @is_send = course.is_send
      perform_request(updated_is_send)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "does not change `is_send` attribute" do
      expect(course.reload.is_send).to eq(@is_send)
    end
  end
end
