require 'rails_helper'

describe 'Courses API v2', type: :request do
  describe 'GET index' do
    let(:user) { create(:user) }
    let(:organisation) { create(:organisation, users: [user]) }
    let(:payload) { { email: user.email } }
    let(:token) do
      JWT.encode payload.to_json,
                 Settings.authentication.secret,
                 Settings.authentication.algorithm
    end
    let(:credentials) do
      ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    let(:findable_open_course) {
      create(:course,
             start_date: Time.now.utc,
             site_statuses: [create(:site_status, :findable, :with_any_vacancy, :applications_being_accepted_now)])
    }
    let(:provider) {
      create(:provider,
             course_count: 0,
             courses: [findable_open_course],
             organisations: [organisation])
    }
    subject { response }

    context 'when unauthenticated' do
      let(:payload) { { email: 'foo@bar' } }

      before do
        get "/api/v2/providers/#{provider.provider_code}/courses",
            headers: { 'HTTP_AUTHORIZATION' => credentials }
      end

      it { should have_http_status(:unauthorized) }
    end

    context 'when unauthorised' do
      let(:unauthorised_user) { create(:user) }
      let(:payload) { { email: unauthorised_user.email } }

      it "raises an error" do
        expect {
          get "/api/v2/providers/#{provider.provider_code}/courses",
            headers: { 'HTTP_AUTHORIZATION' => credentials }
        }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe 'JSON generated for courses' do
      before do
        get "/api/v2/providers/#{provider.provider_code}/courses",
            headers: { 'HTTP_AUTHORIZATION' => credentials }
      end

      it { should have_http_status(:success) }

      it 'has a data section with the correct attributes' do
        json_response = JSON.parse response.body
        expect(json_response).to eq(
          "data" => [{
            "id" => provider.courses[0].id.to_s,
            "type" => "courses",
            "attributes" => {
              "findable?" => true,
              "open_for_applications?" => true,
              "has_vacancies?" => true,
              "name" => provider.courses[0].name,
              "course_code" => provider.courses[0].course_code,
              "profpost_flag" => provider.courses[0].profpost_flag,
              "start_date" => provider.courses[0].start_date.iso8601,
              "study_mode" => provider.courses[0].study_mode,
            },
            "relationships" => {
              "accrediting_provider" => { "meta" => { "included" => false } },
              "provider" => { "meta" => { "included" => false } },
            },
          }],
          "jsonapi" => {
            "version" => "1.0"
          }
        )
      end
    end

    it "raises a 'record not found' error when the provider doesn't exist" do
      expect {
        get("/api/v2/providers/non-existent-provider/courses",
         headers: { 'HTTP_AUTHORIZATION' => credentials })
      } .to raise_error ActiveRecord::RecordNotFound
    end
  end
end
