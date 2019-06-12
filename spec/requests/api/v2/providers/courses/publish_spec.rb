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
    let(:enrichment) { build(:course_enrichment, :initial_draft) }
    let(:course) {
      create(:course,
             provider: provider,
             with_site_statuses: [:new],
             enrichments: [enrichment])
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

      it { should have_http_status(:not_found) }
    end

    context 'unpublished course with draft enrichment' do\
      let(:enrichment) { build(:course_enrichment, :initial_draft) }
      let!(:course) {
        create(:course,
               provider: provider,
               with_site_statuses: [:new],
              enrichments: [enrichment],
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

      it 'raises an error' do
        expect {
          subject
        }.to raise_error RuntimeError,
                         'error received when syncing with search and compare'
      end
    end

    context 'when the api sets http status to 500' do
      let(:manage_api_status) { 500 }
      let(:manage_api_response) { '{ "result": true }' }

      it 'raises an error' do
        expect {
          subject
        }.to raise_error RuntimeError,
                         'error received when syncing with search and compare'
      end
    end

    describe 'failed validation' do
      let(:json_data) { JSON.parse(subject.body)['errors'] }

      context 'no enrichments' do
        let(:course) { create(:course, provider: provider) }
        it { should have_http_status(:unprocessable_entity) }
        it 'has validation errors' do
          expect(json_data.count).to eq 1
          expect(response.body).to include('Invalid enrichment')
          expect(response.body).to include("Enrichments can't be blank")
        end
      end

      context 'fee type based course' do
        let(:course) { create(:course, :fee_type_based, provider: provider, enrichments: [invalid_enrichment]) }

        context 'invalid enrichment with invalid content exceed word count fields' do
          let(:invalid_enrichment) {
            create(:course_enrichment, :with_fee_based_course,
                   about_course:  Faker::Lorem.sentence(400 + 1),
                             interview_process:  Faker::Lorem.sentence(250 + 1),
                             qualifications:  Faker::Lorem.sentence(100 + 1),
                             how_school_placements_work:  Faker::Lorem.sentence(350 + 1),
                             fee_details:  Faker::Lorem.sentence(250 + 1),
                             salary_details:  Faker::Lorem.sentence(250 + 1))
          }

          it { should have_http_status(:unprocessable_entity) }

          it 'has validation errors' do
            expect(json_data.count).to eq 5
            expect(json_data[0]["detail"]).to eq("Reduce the word count for about course")
            expect(json_data[1]["detail"]).to eq("Reduce the word count for interview process")
            expect(json_data[2]["detail"]).to eq("Reduce the word count for how school placements work")
            expect(json_data[3]["detail"]).to eq("Reduce the word count for qualifications")
            expect(json_data[4]["detail"]).to eq("Reduce the word count for fee details")
          end
        end

        context 'invalid enrichment with invalid content lack_presence fields' do
          let(:invalid_enrichment) { create(:course_enrichment, :without_content) }

          it { should have_http_status(:unprocessable_entity) }

          it 'has validation errors' do
            expect(json_data.count).to eq 5
            expect(json_data[0]["detail"]).to eq("Enter details about this course")
            expect(json_data[1]["detail"]).to eq("Enter details about school placements")
            expect(json_data[2]["detail"]).to eq("Enter a course length")
            expect(json_data[3]["detail"]).to eq("Enter details about the qualifications needed")
            expect(json_data[4]["detail"]).to eq("Give details about the fee for UK and EU students")
          end
        end
      end

      context 'salary type based course' do
        let(:course) { create(:course, :salary_type_based, provider: provider, enrichments: [invalid_enrichment]) }

        context 'invalid enrichment with invalid content exceed word count fields' do
          let(:invalid_enrichment) {
            create(:course_enrichment, :with_fee_based_course,
                   about_course:  Faker::Lorem.sentence(400 + 1),
                             interview_process:  Faker::Lorem.sentence(250 + 1),
                             qualifications:  Faker::Lorem.sentence(100 + 1),
                             how_school_placements_work:  Faker::Lorem.sentence(350 + 1),
                             fee_details:  Faker::Lorem.sentence(250 + 1),
                             salary_details:  Faker::Lorem.sentence(250 + 1))
          }

          it { should have_http_status(:unprocessable_entity) }

          it 'has validation errors' do
            expect(json_data.count).to eq 5
            expect(json_data[0]["detail"]).to eq("Reduce the word count for about course")
            expect(json_data[1]["detail"]).to eq("Reduce the word count for interview process")
            expect(json_data[2]["detail"]).to eq("Reduce the word count for how school placements work")
            expect(json_data[3]["detail"]).to eq("Reduce the word count for qualifications")
            expect(json_data[4]["detail"]).to eq("Reduce the word count for salary details")
          end
        end
        context 'invalid enrichment with invalid content lack_presence fields' do
          let(:invalid_enrichment) { create(:course_enrichment, :without_content) }

          it { should have_http_status(:unprocessable_entity) }

          it 'has validation errors' do
            expect(json_data.count).to eq 5
            expect(json_data[0]["detail"]).to eq("Enter details about this course")
            expect(json_data[1]["detail"]).to eq("Enter details about school placements")
            expect(json_data[2]["detail"]).to eq("Enter a course length")
            expect(json_data[3]["detail"]).to eq("Enter details about the qualifications needed")
            expect(json_data[4]["detail"]).to eq("Give details about the salary for this course")
          end
        end
      end
    end
  end
end
