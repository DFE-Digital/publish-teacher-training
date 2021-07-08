require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_additional_gcse_equivalencies)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    jsonapi_data[:data][:attributes] = updated_additional_gcse_equivalencies

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
           additional_gcse_equivalencies: "Must have a cycling proficiency certificate."
  }
  let(:permitted_params) do
    %i[additional_gcse_equivalencies]
  end

  context "course has different additional_gcse_equivalencies" do
    let(:updated_additional_gcse_equivalencies) { { additional_gcse_equivalencies: "Must have a physics A level." } }

    it "returns http success" do
      perform_request(updated_additional_gcse_equivalencies)
      expect(response).to have_http_status(:success)
    end

    it "updates the additional_gcse_equivalencies attribute to the correct value" do
      expect {
        perform_request(updated_additional_gcse_equivalencies)
      }.to change { course.reload.additional_gcse_equivalencies }
            .from("Must have a cycling proficiency certificate.").to("Must have a physics A level.")
    end
  end

  context "course has the same additional_gcse_equivalencies" do
    context "with values passed into the params" do
      let(:updated_additional_gcse_equivalencies) { { additional_gcse_equivalencies: "Must have a cycling proficiency certificate." } }

      it "returns http success" do
        perform_request(updated_additional_gcse_equivalencies)
        expect(response).to have_http_status(:success)
      end

      it "does not change additional_gcse_equivalencies attribute" do
        expect {
          perform_request(updated_additional_gcse_equivalencies)
        }.to_not change { course.reload.additional_gcse_equivalencies }
             .from("Must have a cycling proficiency certificate.")
      end
    end
  end

  context "with no values passed into the params" do
    let(:updated_additional_gcse_equivalencies) { {} }

    it "returns http success" do
      perform_request(updated_additional_gcse_equivalencies)
      expect(response).to have_http_status(:success)
    end

    it "does not change additional_gcse_equivalencies attribute" do
      expect {
        perform_request(updated_additional_gcse_equivalencies)
      }.to_not change { course.reload.additional_gcse_equivalencies }
           .from("Must have a cycling proficiency certificate.")
    end
  end

  context "when nil is passed into the params" do
    let(:updated_additional_gcse_equivalencies) { { additional_gcse_equivalencies: nil } }

    it "returns http success" do
      perform_request(updated_additional_gcse_equivalencies)
      expect(response).to have_http_status(:success)
    end

    it "updates the additional_gcse_equivalencies attribute to nil" do
      expect {
        perform_request(updated_additional_gcse_equivalencies)
      }.to change { course.reload.additional_gcse_equivalencies }
            .from("Must have a cycling proficiency certificate.").to(nil)
    end
  end
end
