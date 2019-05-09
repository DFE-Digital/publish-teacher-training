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

      it { should have_http_status(:not_found) }
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
      let(:json_data) { JSON.parse(subject.body)['errors'] }

      context 'no enrichments' do
        let(:course) { create(:course, provider: provider, with_enrichments: []) }
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
          let(:invalid_enrichment) { create(:course_enrichment, :with_invalid_content_exceed_word_count_fields) }

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
          let(:invalid_enrichment) { create(:course_enrichment, :with_invalid_content_lack_presence_fields) }

          it { should have_http_status(:unprocessable_entity) }

          it 'has validation errors' do
            expect(json_data.count).to eq 3
            expect(json_data[0]["detail"]).to eq("About course can't be blank")
            expect(json_data[1]["detail"]).to eq("Qualifications can't be blank")
            expect(json_data[2]["detail"]).to eq("Enter course fees for UK and EU students")
          end
        end
      end
      context 'salary type based course' do
        let(:course) { create(:course, :salary_type_based, provider: provider, enrichments: [invalid_enrichment]) }

        context 'invalid enrichment with invalid content exceed word count fields' do
          let(:invalid_enrichment) { create(:course_enrichment, :with_invalid_content_exceed_word_count_fields) }

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
          let(:invalid_enrichment) { create(:course_enrichment, :with_invalid_content_lack_presence_fields) }

          it { should have_http_status(:unprocessable_entity) }

          it 'has validation errors' do
            expect(json_data.count).to eq 3
            expect(json_data[0]["detail"]).to eq("About course can't be blank")
            expect(json_data[1]["detail"]).to eq("Qualifications can't be blank")
            expect(json_data[2]["detail"]).to eq("Enter salary details")
          end
        end
      end
    end
  end
end
