require 'rails_helper'

describe 'Course POST #create API V2', type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt(:apiv2, payload: payload) }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
  let(:provider)     { build(:provider, organisations: [organisation]) }
  let(:recruitment_cycle) { provider.recruitment_cycle }
  let(:course)       {  create(:course, provider: provider) }
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:create_path) do
    "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" +
    "/providers/#{course.provider.provider_code}/courses"
  end

  def perform_request(course)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse
      }
    )

    jsonapi_data.dig(:data, :attributes).slice!(*permitted_params)

    post  create_path,
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: {
            _jsonapi: jsonapi_data
          }
  end

  let(:permitted_params) do
    %i[
      name
      study_mode
      qualifications
      english
      maths
      science
      qualification
      age_range_in_years
      start_date
      applications_open_from
      study_mode
      is_send
    ]
  end

  context 'when unauthenticated' do
    subject do
      perform_request(course)
      response
    end

    let(:payload) { { email: 'foo@bar' } }

    it { should have_http_status(:unauthorized) }
  end

  context 'when unauthorized' do
    let(:unauthorised_user) { create(:user) }
    let(:payload) { { email: unauthorised_user.email } }

    it "raises an error" do
      expect { perform_request(course) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  context 'when authorised' do
  end
end
