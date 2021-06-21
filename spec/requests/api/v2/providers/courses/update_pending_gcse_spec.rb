require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_pending_gcse)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    jsonapi_data[:data][:attributes] = updated_pending_gcse

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
  let(:credentials)       { encode_to_credentials(payload) }

  let(:course)            {
    create :course,
           provider: provider,
           accept_pending_gcse: false
  }
  let(:permitted_params) do
    %i[accept_pending_gcse]
  end

  context "course has an updated_pending_gcse" do
    let(:updated_pending_gcse) { { accept_pending_gcse: true } }

    it "returns http success" do
      perform_request(updated_pending_gcse)
      expect(response).to have_http_status(:success)
    end

    it "updates the updated_pending_gcse attribute to the correct value" do
      expect {
        perform_request(updated_pending_gcse)
      }.to change { course.reload.accept_pending_gcse }
             .from(false).to(true)
    end
  end

  context "course has the same updated_pending_gcse" do
    context "with values passed into the params" do
      let(:updated_pending_gcse) { { accept_pending_gcse: false } }

      it "returns http success" do
        perform_request(updated_pending_gcse)
        expect(response).to have_http_status(:success)
      end

      it "does not change updated_pending_gcse attribute" do
        expect {
          perform_request(updated_pending_gcse)
        }.to_not change { course.reload.accept_pending_gcse }
             .from(false)
      end
    end
  end

  context "with no values passed into the params" do
    let(:updated_pending_gcse) { {} }

    it "returns http success" do
      perform_request(updated_pending_gcse)
      expect(response).to have_http_status(:success)
    end

    it "does not change updated_pending_gcse attribute" do
      expect {
        perform_request(updated_pending_gcse)
      }.to_not change { course.reload.accept_pending_gcse }
           .from(false)
    end
  end
end
