require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(funding_type)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    jsonapi_data[:data][:attributes] = funding_type

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
           :with_accrediting_provider,
           provider: provider,
           program_type: program_type
  }
  let(:program_type) { :school_direct_training_programme }

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:permitted_params) do
    %i[funding_type]
  end

  before do
    perform_request(funding_type)
  end

  context "course has an updated program type" do
    let(:funding_type) { { funding_type: "salary" } }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the program_type attribute to the correct value" do
      expect(course.reload.program_type).to eq("school_direct_salaried_training_programme")
    end
  end

  context "with no values passed into the params" do
    let(:funding_type) { {} }
    let!(:previous_program_type) { course.program_type }

    before do
      perform_request(funding_type)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "does not change program_type attribute" do
      expect(course.reload.program_type).to eq(previous_program_type)
    end
  end
end
