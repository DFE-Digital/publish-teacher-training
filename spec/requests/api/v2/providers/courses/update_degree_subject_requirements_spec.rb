require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_degree_subject_requirements)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    jsonapi_data[:data][:attributes] = updated_degree_subject_requirements

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
           degree_subject_requirements: "Must have a Maths A level."
  }
  let(:permitted_params) do
    %i[degree_subject_requirements]
  end

  context "course has different degree_subject_requirements" do
    let(:updated_degree_subject_requirements) { { degree_subject_requirements: "Must have a Physics A level." } }

    it "returns http success" do
      perform_request(updated_degree_subject_requirements)
      expect(response).to have_http_status(:success)
    end

    it "updates the degree_subject_requirements attribute to the correct value" do
      expect {
        perform_request(updated_degree_subject_requirements)
      }.to change { course.reload.degree_subject_requirements }
            .from("Must have a Maths A level.").to("Must have a Physics A level.")
    end
  end

  context "course has the same degree_subject_requirements" do
    context "with values passed into the params" do
      let(:updated_degree_subject_requirements) { { degree_subject_requirements: "Must have a Maths A level." } }

      it "returns http success" do
        perform_request(updated_degree_subject_requirements)
        expect(response).to have_http_status(:success)
      end

      it "does not change degree_subject_requirements attribute" do
        expect {
          perform_request(updated_degree_subject_requirements)
        }.to_not change { course.reload.degree_subject_requirements }
             .from("Must have a Maths A level.")
      end
    end
  end

  context "with no values passed into the params" do
    let(:updated_degree_subject_requirements) { {} }

    it "returns http success" do
      perform_request(updated_degree_subject_requirements)
      expect(response).to have_http_status(:success)
    end

    it "does not change degree_subject_requirements attribute" do
      expect {
        perform_request(updated_degree_subject_requirements)
      }.to_not change { course.reload.degree_subject_requirements }
           .from("Must have a Maths A level.")
    end
  end

  context "when nil is passed into the params" do
    let(:updated_degree_subject_requirements) { { degree_subject_requirements: nil } }

    it "returns http success" do
      perform_request(updated_degree_subject_requirements)
      expect(response).to have_http_status(:success)
    end

    it "updates the degree_subject_requirements attribute to nil" do
      expect {
        perform_request(updated_degree_subject_requirements)
      }.to change { course.reload.degree_subject_requirements }
            .from("Must have a Maths A level.").to(nil)
    end
  end
end
