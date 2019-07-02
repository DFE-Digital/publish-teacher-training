describe 'Courses API v2', type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
  let(:site) { build(:site) }
  let(:dfe_subject) { build(:subject, subject_name: "primary") }
  let(:non_dfe_subject) { build(:subject, subject_name: "secondary") }
  let(:findable_site_status_1) { build(:site_status, :findable, site: site) }
  let(:findable_site_status_2) { build(:site_status, :findable, site: site) }
  let(:suspended_site_status) { build(:site_status, :suspended, site: site) }
  let(:syncable_course) { build(:course, site_statuses: [findable_site_status_1], subjects: [dfe_subject]) }
  let(:suspended_course) { build(:course, site_statuses: [suspended_site_status], subjects: [dfe_subject]) }
  let(:invalid_subject_course) { build(:course, site_statuses: [findable_site_status_2], subjects: [non_dfe_subject]) }
  let(:provider) { create(:provider, organisations: [organisation], courses: [syncable_course, suspended_course, invalid_subject_course], sites: [site]) }


  subject { response }

  describe 'POST ' do
    let(:sync_path) do
      "/api/v2/providers/#{provider.provider_code}/sync_courses_with_search_and_compare"
    end
    let(:status) { 200 }
    let(:has_synced) { true }

    before do
      stub_request(:put, "#{Settings.search_api.base_url}/api/courses/")
        .to_return(
          status: status,
        )
      allow(SearchAndCompareAPIService::Request).to receive(:sync).with([syncable_course]).and_return(has_synced)
    end

    subject do
      post sync_path, headers: { 'HTTP_AUTHORIZATION' => credentials }
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

    context 'when authorized' do
      context 'when a successful external call to search has been made' do
      it { should have_http_status(:ok) }
      end

      context 'when an unsuccessful external call to search has been made' do
        let(:has_synced) { false }
        it 'should throw an error' do
          expect { subject }.to raise_error('error received when syncing courses with search and compare')
        end
      end
    end
  end
end
