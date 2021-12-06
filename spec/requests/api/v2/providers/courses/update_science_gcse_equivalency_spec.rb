require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_science_gcse_equivalency)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    jsonapi_data[:data][:attributes] = updated_science_gcse_equivalency

    patch "/api/v2/providers/#{course.provider.provider_code}" \
          "/courses/#{course.course_code}",
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: {
            _jsonapi: jsonapi_data,
          }
  end
  let(:provider)          { create :provider, users: [user] }
  let(:user)              { create :user }
  let(:payload)           { { email: user.email } }
  let(:credentials)       { encode_to_credentials(payload) }

  let(:course)            {
    create :course,
           provider: provider,
           accept_science_gcse_equivalency: false
  }
  let(:permitted_params) do
    %i[accept_science_gcse_equivalency]
  end

  context "course has an updated_science_gcse_equivalency" do
    let(:updated_science_gcse_equivalency) { { accept_science_gcse_equivalency: true } }

    it "returns http success" do
      perform_request(updated_science_gcse_equivalency)
      expect(response).to have_http_status(:success)
    end

    it "updates the updated_science_gcse_equivalency attribute to the correct value" do
      expect {
        perform_request(updated_science_gcse_equivalency)
      }.to change { course.reload.accept_science_gcse_equivalency }
             .from(false).to(true)
    end
  end

  context "course has the same updated_science_gcse_equivalency" do
    context "with values passed into the params" do
      let(:updated_science_gcse_equivalency) { { accept_science_gcse_equivalency: false } }

      it "returns http success" do
        perform_request(updated_science_gcse_equivalency)
        expect(response).to have_http_status(:success)
      end

      it "does not change updated_science_gcse_equivalency attribute" do
        expect {
          perform_request(updated_science_gcse_equivalency)
        }.to_not change { course.reload.accept_science_gcse_equivalency }
             .from(false)
      end
    end
  end

  context "with no values passed into the params" do
    let(:updated_science_gcse_equivalency) { {} }

    it "returns http success" do
      perform_request(updated_science_gcse_equivalency)
      expect(response).to have_http_status(:success)
    end

    it "does not change updated_science_gcse_equivalency attribute" do
      expect {
        perform_request(updated_science_gcse_equivalency)
      }.to_not change { course.reload.accept_science_gcse_equivalency }
           .from(false)
    end
  end
end
