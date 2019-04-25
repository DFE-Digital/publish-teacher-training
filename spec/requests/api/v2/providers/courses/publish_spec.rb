require 'rails_helper'

describe 'Publish API v2', type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:provider)       { create :provider, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  describe 'POST publish' do
    let(:manage_api_status) { 200 }
    let(:manage_api_response) { '{ "result": true }' }
    let(:course) { findable_open_course }
    let(:publish_path) do
      "/api/v2/providers/#{provider.provider_code}" +
        "/courses/#{course.course_code}/publish"
    end

    before do
      stub_request(:post, %r{#{Settings.manage_api.base_url}/api/Publish/internal/course/})
        .to_return(
          status: manage_api_status,
          body: manage_api_response
        )
    end
    let(:course) {
      create(:course,
             provider: provider,
             with_site_statuses: [:new],
             with_enrichments: [:initial_draft])
    }

    subject do
      post publish_path, headers: { 'HTTP_AUTHORIZATION' => credentials }
      response
    end

    context 'when unauthenticated' do
      let(:payload) { { email: 'foo@bar' } }

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

    context 'unpublished course with draft enrichment' do
      let!(:course) {
        create(:course,
               provider: provider,
               with_site_statuses: [:new],
               with_enrichments: [:initial_draft],
               age: 17.days.ago)
      }
      it 'publishes a course' do
        expect(subject).to have_http_status(:success)
        assert_requested :post, %r{#{Settings.manage_api.base_url}/api/Publish/internal/course/}

        expect(course.reload.site_statuses.first).to be_status_running
        expect(course.site_statuses.first).to be_published_on_ucas
        expect(course.enrichments.first).to be_published
        expect(course.enrichments.first.updated_by_user_id).to eq user.id
        expect(course.enrichments.first.updated_at).to be_within(1.second).of Time.now.utc
        expect(course.enrichments.first.last_published_timestamp_utc).to be_within(1.second).of Time.now.utc
        expect(course.changed_at).to be_within(1.second).of Time.now.utc
      end
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
  end
end
