require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:organisation)      { create :organisation }
  let(:provider)          { create :provider, organisations: [organisation] }
  let(:user)              { create :user, organisations: [organisation] }
  let(:payload)           { { email: user.email } }
  let(:credentials)       { encode_to_credentials(payload) }
  let(:course)            do
    create :course,
           provider: provider,
           additional_degree_subject_requirements: true
  end
  let(:permitted_params) do
    %i[additional_degree_subject_requirements]
  end

  def perform_request(updated_additional_degree_subject_requirements)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    jsonapi_data[:data][:attributes] = updated_additional_degree_subject_requirements

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

  let(:course)            do
    create :course,
           provider: provider,
           additional_degree_subject_requirements: true
  end
  let(:permitted_params) do
    %i[additional_degree_subject_requirements]
  end

  context "course has an updated_additional_degree_subject_requirements" do
    let(:updated_additional_degree_subject_requirements) { { additional_degree_subject_requirements: false } }

    it "returns http success" do
      perform_request(updated_additional_degree_subject_requirements)
      expect(response).to have_http_status(:success)
    end

    it "updates the updated_additional_degree_subject_requirements attribute to the correct value" do
      expect {
        perform_request(updated_additional_degree_subject_requirements)
      }.to change { course.reload.additional_degree_subject_requirements }
             .from(true).to(false)
    end
  end

  context "course has the same updated_additional_degree_subject_requirements" do
    context "with values passed into the params" do
      let(:updated_additional_degree_subject_requirements) { { additional_degree_subject_requirements: true } }

      it "returns http success" do
        perform_request(updated_additional_degree_subject_requirements)
        expect(response).to have_http_status(:success)
      end

      it "does not change updated_additional_degree_subject_requirements attribute" do
        expect {
          perform_request(updated_additional_degree_subject_requirements)
        }.not_to change { course.reload.additional_degree_subject_requirements }
             .from(true)
      end
    end
  end

  context "with no values passed into the params" do
    let(:updated_additional_degree_subject_requirements) { {} }

    it "returns http success" do
      perform_request(updated_additional_degree_subject_requirements)
      expect(response).to have_http_status(:success)
    end

    it "does not change updated_additional_degree_subject_requirements attribute" do
      expect {
        perform_request(updated_additional_degree_subject_requirements)
      }.not_to change { course.reload.additional_degree_subject_requirements }
           .from(true)
    end
  end
end
