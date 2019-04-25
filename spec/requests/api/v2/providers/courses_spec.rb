require 'rails_helper'

describe 'Courses API v2', type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:course_subject_primary) { find_or_create(:subject, subject_name: 'Primary', subject_code: 'P') }
  let(:course_subject_mathematics) { find_or_create(:subject, subject_name: 'Mathematics', subject_code: 'M') }
  let(:course_subject_send) { find_or_create(:send_subject) }

  let(:findable_open_course) {
    create(:course, :resulting_in_pgce_with_qts, :with_apprenticeship,
           name: "Primary (Mathematics Specialist)",
           provider: provider,
           start_date: Time.now.utc,
           study_mode: :full_time,
           subject_count: 0,
           subjects: [course_subject_primary, course_subject_mathematics, course_subject_send],
           with_site_statuses: [%i[findable with_any_vacancy applications_being_accepted_from_2019]],
           enrichments: [enrichment])
  }

  let(:enrichment)     { build :course_enrichment }
  let(:provider)       { create :provider, organisations: [organisation] }
  let(:course_subject) { course.subjects.first }
  let(:site_status)    { findable_open_course.site_statuses.first }
  let(:site)           { site_status.site }

  subject { response }

  describe 'GET show' do
    let(:show_path) do
      "/api/v2/providers/#{provider.provider_code}" +
        "/courses/#{course.course_code}"
    end
    let(:course) { findable_open_course }

    subject do
      get show_path, headers: { 'HTTP_AUTHORIZATION' => credentials }
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
      it "raises an error" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    describe 'JSON generated for courses' do
      before do
        get "/api/v2/providers/#{provider.provider_code.downcase}/courses/#{findable_open_course.course_code.downcase}",
            headers: { 'HTTP_AUTHORIZATION' => credentials },
            params: { include: 'subjects,site_statuses.site' }
      end

      it { should have_http_status(:success) }

      it 'has a data section with the correct attributes' do
        json_response = JSON.parse response.body
        expect(json_response).to eq(
          "data" => {
            "id" => provider.courses[0].id.to_s,
            "type" => "courses",
            "attributes" => {
              "findable?" => true,
              "open_for_applications?" => true,
              "has_vacancies?" => true,
              "name" => provider.courses[0].name,
              "course_code" => provider.courses[0].course_code,
              "start_date" => provider.courses[0].start_date.iso8601,
              "study_mode" => "full_time",
              "qualifications" => %w[qts pgce],
              "description" => "PGCE with QTS full time teaching apprenticeship",
              "content_status" => "draft",
              "ucas_status" => "running",
              "funding" => "apprenticeship",
              "is_send?" => true,
              "subjects" => ["Primary",
                             "Primary with mathematics"],
              "level" => "primary",
              "applications_open_from" => "2019-01-01T00:00:00Z",
              "about_course" => enrichment.about_course,
              "course_length" => enrichment.course_length,
              "fee_details" => enrichment.fee_details,
              "fee_international" => enrichment.fee_international,
              "fee_uk_eu" => enrichment.fee_uk_eu,
              "financial_support" => enrichment.financial_support,
              "how_school_placements_work" => enrichment.how_school_placements_work,
              "interview_process" => enrichment.interview_process,
              "other_requirements" => enrichment.other_requirements,
              "personal_qualities" => enrichment.personal_qualities,
              "required_qualifications" => enrichment.qualifications,
              "salary_details" => enrichment.salary_details
            },
            "relationships" => {
              "accrediting_provider" => { "meta" => { "included" => false } },
              "provider" => { "meta" => { "included" => false } },
              "site_statuses" => { "data" => [{ "type" => "site_statuses", "id" => site_status.id.to_s }] },
            },
          },
          "jsonapi" => {
            "version" => "1.0"
          },
          "included" => [{
            "id" => site_status.id.to_s,
            "type" => "site_statuses",
            "attributes" => {
              "vac_status" => site_status.vac_status,
              "publish" => site_status.publish,
              "status" => site_status.status,
              "applications_accepted_from" => site_status.applications_accepted_from.strftime("%Y-%m-%d")
            },
            "relationships" => {
              "site" => {
                "data" => {
                  "type" => "sites",
                    "id" => site.id.to_s
                  }
                }
              }
            }, {
            "id" => site.id.to_s,
            "type" => "sites",
            "attributes" => {
              "code" => site.code,
              "location_name" => site.location_name,
              "address1" => site.address1,
              "address2" => site.address2,
              "address3" => site.address3,
              "address4" => site.address4,
              "postcode" => site.postcode,
              "region_code" => site.region_code
            }
          }]
        )
      end
    end
  end

  describe 'POST sync_with_search_and_compare' do
    let(:manage_api_status) { 200 }
    let(:manage_api_response) { '{ "result": true }' }
    let!(:stubbed_manage_courses_api_request) do
      stub_request(:post, %r{#{Settings.manage_api.base_url}/api/Publish/internal/course/})
        .to_return(
          status: manage_api_status,
          body: manage_api_response
        )
    end
    let(:sync_path) do
      "/api/v2/providers/#{provider.provider_code}" +
        "/courses/#{course.course_code}/sync_with_search_and_compare"
    end
    let(:course) { findable_open_course }

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
  end

  describe 'GET index' do
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
        findable_open_course
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
              "start_date" => provider.courses[0].start_date.iso8601,
              "study_mode" => "full_time",
              "qualifications" => %w[qts pgce],
              "description" => "PGCE with QTS full time teaching apprenticeship",
              "content_status" => "draft",
              "ucas_status" => "running",
              "funding" => "apprenticeship",
              "is_send?" => true,
              "subjects" => ["Primary",
                             "Primary with mathematics"],
              "level" => "primary",
              "applications_open_from" => "2019-01-01T00:00:00Z",
              "about_course" => enrichment.about_course,
              "course_length" => enrichment.course_length,
              "fee_details" => enrichment.fee_details,
              "fee_international" => enrichment.fee_international,
              "fee_uk_eu" => enrichment.fee_uk_eu,
              "financial_support" => enrichment.financial_support,
              "how_school_placements_work" => enrichment.how_school_placements_work,
              "interview_process" => enrichment.interview_process,
              "other_requirements" => enrichment.other_requirements,
              "personal_qualities" => enrichment.personal_qualities,
              "required_qualifications" => enrichment.qualifications,
              "salary_details" => enrichment.salary_details
            },
            "relationships" => {
              "accrediting_provider" => { "meta" => { "included" => false } },
              "provider" => { "meta" => { "included" => false } },
              "site_statuses" => { "meta" => { "included" => false } },
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
