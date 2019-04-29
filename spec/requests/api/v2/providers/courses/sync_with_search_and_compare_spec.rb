require 'rails_helper'

describe 'Courses API v2', type: :request do
  let(:user) { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:provider)       { create :provider, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  describe 'POST sync_with_search_and_compare' do
    let(:manage_api_status) { 200 }
    let(:manage_api_response) { '{ "result": true }' }
    let(:sync_path) do
      "/api/v2/providers/#{provider.provider_code}" +
        "/courses/#{course.course_code}/sync_with_search_and_compare"
    end

    let(:course) { create(:course, provider: provider, with_enrichments: [:initial_draft]) }

    before do
      stub_request(:post, %r{#{Settings.manage_api.base_url}/api/Publish/internal/course/})
        .to_return(
          status: manage_api_status,
          body: manage_api_response
        )
    end

    subject do
      post sync_path, headers: { 'HTTP_AUTHORIZATION' => credentials }
      response
    end

    context 'when unauthenticated' do
      let(:payload) { { email: 'foo@bar' } }
      let(:credentials) do
        ActionController::HttpAuthentication::Token.encode_credentials(token)
      end

      it { should have_http_status(:unauthorized) }
    end

    context 'when user has not accepted terms' do
      let(:user)         { create(:user, accept_terms_date_utc: nil) }
      let(:organisation) { create(:organisation, users: [user]) }

      it { should have_http_status(:forbidden) }
    end

    context 'when unauthorised' do
      let(:unauthorised_user) { create(:user) }
      let(:payload)           { { email: unauthorised_user.email } }

      it "raises an error" do
        expect { subject }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context 'when course and provider is not related' do
      let(:course) { create(:course) }

      it 'raises an error' do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'when the api responds with a success' do
      it { should have_http_status(:success) }
    end

    context 'when the api responds with result: false' do
      let(:manage_api_response) { '{ "result": false }' }

      it { should have_http_status(:internal_server_error) }
    end

    context 'when the api sets http status to 500' do
      let(:manage_api_status) { 500 }
      let(:manage_api_response) { '{ "result": true }' }
      it { should have_http_status(:internal_server_error) }
    end

    describe 'failed validation' do
      context 'no enrichments' do
        let(:course) { create(:course, provider: provider, with_enrichments: []) }
        it { should have_http_status(:unprocessable_entity) }
        it 'has validation errors' do
          expect(subject.body).to include('errors')
        end
      end

      context 'invalid enrichment' do
        let(:invalid_enrichment) {
          create(:course_enrichment,
         about_course: (%w[word] * 400).join(' ') + " exceeeded")
        }
        let(:course) { create(:course, provider: provider, enrichments: [invalid_enrichment]) }
        it { should have_http_status(:unprocessable_entity) }
        it 'has validation errors' do
          expect(subject.body).to include('errors')
        end
      end
    end
  end
end
