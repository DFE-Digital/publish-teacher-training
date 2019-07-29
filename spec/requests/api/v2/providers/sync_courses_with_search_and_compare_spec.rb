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
  let(:provider) {
    create(:provider,
           organisations: [organisation],
             courses: [syncable_course, suspended_course, invalid_subject_course],
             sites: [site])
  }

  describe 'POST ' do
    let(:status) { 200 }
    let(:stubbed_request_body) { WebMock::Matchers::AnyArgMatcher.new(nil) }
    let(:stubbed_request) do
      stub_request(:put, "#{Settings.search_api.base_url}/api/courses/")
        .with(body: stubbed_request_body)
        .to_return(
          status: status,
        )
    end

    before do
      stubbed_request
    end

    subject do
      post sync_path, headers: { 'HTTP_AUTHORIZATION' => credentials }
      response
    end

    let(:sync_path) do
      "/api/v2/providers/#{provider.provider_code}/sync_courses_with_search_and_compare"
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
      context 'current recruitment cycle ' do
        let(:sync_path) do
          "/api/v2/recruitment_cycles/#{provider.recruitment_cycle.year}" +
            "/providers/#{provider.provider_code}/sync_courses_with_search_and_compare"
        end

        context 'when a successful external call to search has been made' do
          let(:stubbed_request_body) { include("\"ProviderCode\":\"#{provider.provider_code}\"", "\"ProgrammeCode\":\"#{syncable_course.course_code}\"") }

          it 'should be successful' do
            expect(subject).to have_http_status(:ok)
          end

          it 'should make the appropriate request' do
            subject
            expect(stubbed_request).to have_been_requested
          end
        end

        context 'when an unsuccessful external call to search has been made' do
          let(:status) { 451 }

          it 'should throw an error' do
            expect { subject }.to raise_error("#{provider} failed to sync these courses #{provider.syncable_courses.pluck(:course_code)}")
          end
        end
      end

      context 'next recruitment cycle' do
        let(:sync_path) do
          "/api/v2/recruitment_cycles/#{provider.recruitment_cycle.year}" +
            "/providers/#{provider.provider_code}/sync_courses_with_search_and_compare"
        end
        let(:next_cycle) { build(:recruitment_cycle, year: 2020) }
        let(:provider) {
          create(:provider,
                 organisations: [organisation],
                         courses: [syncable_course],
                         sites: [site],
                         recruitment_cycle: next_cycle)
        }

        it 'should throw an error' do
          expect { subject }.to raise_error("provider is not from the current recrutiment cycle")
        end
      end
    end
  end
end
