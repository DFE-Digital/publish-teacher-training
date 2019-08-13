require "rails_helper"

describe 'PATCH /providers/:provider_code/courses/:course_code' do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_study_mode)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse
      }
    )

    jsonapi_data[:data][:attributes] = updated_study_mode

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

  let(:course)            {
    create :course,
           provider: provider,
           study_mode: study_mode
  }
  let(:study_mode) { :full_time }

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:permitted_params) do
    %i[study_mode]
  end

  before do
    perform_request(updated_study_mode)
  end

  context "course has an updated age range in years" do
    let(:updated_study_mode) { { study_mode: :part_time } }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the study_mode attribute to the correct value" do
      expect(course.reload.study_mode).to eq(updated_study_mode[:study_mode].to_s)
    end
  end

  context "with no values passed into the params" do
    let!(:courses_study_mode) { course.study_mode }
    let(:updated_study_mode) { {} }

    before do
      perform_request(updated_study_mode)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "does not change age_range_in_years attribute" do
      expect(course.reload.study_mode).to eq(courses_study_mode)
    end
  end
end
