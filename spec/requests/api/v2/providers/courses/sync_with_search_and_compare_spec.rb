require "rails_helper"

describe "Courses API v2", type: :request do
  let(:user) { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:provider)       { create :provider, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  describe "POST sync_with_search_and_compare" do
    let(:search_api_status) { 200 }
    let(:sync_path) do
      "/api/v2/providers/#{provider.provider_code}" +
        "/courses/#{course.course_code}/sync_with_search_and_compare"
    end
    let(:course_enrichment) { build(:course_enrichment, :initial_draft) }
    let(:site_status) { build(:site_status, :findable) }
    let(:dfe_subject) { build(:ucas_subject, subject_name: "primary") }
    let(:course) { create(:course, provider: provider, enrichments: [course_enrichment], site_statuses: [site_status], subjects: [dfe_subject]) }

    before do
      stub_request(:put, %r{#{Settings.search_api.base_url}/api/courses/})
        .to_return(
          status: search_api_status,
        )
    end

    subject do
      post sync_path, headers: { "HTTP_AUTHORIZATION" => credentials }
      response
    end

    it { should have_http_status(:success) }

    its(:body) { should be_empty }

    it "makes syncs to search and compare" do
      perform_enqueued_jobs do
        subject
      end

      expect(WebMock)
        .to have_requested(:put, "#{Settings.search_api.base_url}/api/courses/")
    end

    context "when unauthenticated" do
      let(:payload) { { email: "foo@bar" } }
      let(:credentials) do
        ActionController::HttpAuthentication::Token.encode_credentials(token)
      end

      it { should have_http_status(:unauthorized) }
    end

    context "when user has not accepted terms" do
      let(:user)         { create(:user, accept_terms_date_utc: nil) }
      let(:organisation) { create(:organisation, users: [user]) }

      it { should have_http_status(:forbidden) }
    end

    context "when unauthorised" do
      let(:unauthorised_user) { create(:user) }
      let(:payload)           { { email: unauthorised_user.email } }

      it "raises an error" do
        expect { subject }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context "when course and provider is not related" do
      let(:course) { create(:course) }

      it { should have_http_status(:not_found) }
    end
  end
end
