require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

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
  let(:organisation)      { create :organisation }
  let(:provider)          { create :provider, organisations: [organisation] }
  let(:user)              { create :user, organisations: [organisation] }
  let(:payload)           { { email: user.email } }
  let(:credentials)       { encode_to_credentials(payload) }

  let(:course)            {
    create :course,
           provider: provider,
           additional_degree_subject_requirements: true
  }
  let(:permitted_params) do
    %i[additional_degree_subject_requirements]
  end

  before do
    perform_request(updated_additional_degree_subject_requirements)
  end

  context "course has an updated_additional_degree_subject_requirements" do
    let(:updated_additional_degree_subject_requirements) { { additional_degree_subject_requirements: false} }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the updated_additional_degree_subject_requirements attribute to the correct value" do
      expect(course.reload.additional_degree_subject_requirements).to eq(updated_additional_degree_subject_requirements[:additional_degree_subject_requirements])
    end
  end

  context "course has the same updated_additional_degree_subject_requirements" do
    context "with values passed into the params" do
      let(:updated_additional_degree_subject_requirements) { { additional_degree_subject_requirements: true } }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "does not change updated_additional_degree_subject_requirements attribute" do
        expect(course.reload.additional_degree_subject_requirements).to eq(updated_additional_degree_subject_requirements[:additional_degree_subject_requirements])
      end
    end
  end

  context "with no values passed into the params" do
    let(:updated_additional_degree_subject_requirements) { {} }

    before do
      @additional_degree_subject_requirements = course.additional_degree_subject_requirements
      perform_request(updated_additional_degree_subject_requirements)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "does not change updated_additional_degree_subject_requirements attribute" do
      expect(course.reload.additional_degree_subject_requirements).to eq(@additional_degree_subject_requirements)
    end
  end
end
