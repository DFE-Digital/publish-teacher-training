require 'rails_helper'

describe 'Provider Publish API v2', type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:provider)     { create :provider, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  describe 'POST publish' do
    let(:publish_path) do
      "/api/v2/recruitment_cycles/#{provider.recruitment_cycle.year}" +
        "/providers/#{provider.provider_code}/publish"
    end

    let(:enrichment) { build(:provider_enrichment, :initial_draft) }

    subject do
      post publish_path,
           headers: { 'HTTP_AUTHORIZATION' => credentials },
           params: {
             _jsonapi: {
               data: {
                 attributes: {},
                 type: "provider"
               }
             }
           }
      response
    end

    include_examples "Unauthenticated, unauthorised, or not accepted T&Cs"

    context 'unpublished provider with draft enrichment' do
      let(:enrichment) { build(:provider_enrichment, :initial_draft) }
      let(:site1) { create(:site_status, :findable) }
      let(:site2) { create(:site_status, :findable) }
      let(:course1) { build(:course, site_statuses: [site1], subjects: [dfe_subject]) }
      let(:course2) { build(:course, site_statuses: [site2], subjects: [dfe_subject]) }

      let!(:dfe_subject) { build(:subject, subject_name: 'primary') }
      let(:non_dfe_subject) { build(:subject, subject_name: "secondary") }

      let!(:provider) do
        create(
          :provider,
          organisations: [organisation],
          enrichments: [enrichment],
          courses: [course1, course2]
        )
      end

      let(:search_api_status) { 200 }
      let(:sync_body) { WebMock::Matchers::AnyArgMatcher.new(nil) }
      let!(:sync_stub) do
        stub_request(:put, %r{#{Settings.search_api.base_url}/api/courses/})
          .with(body: sync_body)
          .to_return(
            status: search_api_status
          )
      end

      it 'publishes a provider' do
        subject
        enrichment.reload
        expect(enrichment.status).to eq('published')
        expect(enrichment.updated_by_user_id).to eq(user.id)
      end

      context 'when the sync API is available' do
        let(:sync_body) { include("\"ProgrammeCode\":\"#{course1.course_code}\"", "\"ProgrammeCode\":\"#{course2.course_code}\"") }
        it 'syncs a providers courses' do
          subject
          expect(sync_stub).to have_been_requested
        end
      end

      context 'when the sync API is unavailable' do
        let(:search_api_status) { 409 }
        it 'raises an error' do
          expect { subject }.to raise_error(RuntimeError, "#{provider} failed to sync these courses #{[course1.course_code, course2.course_code]}")
        end
      end
    end

    describe 'failed validation' do
      let(:json_data) { JSON.parse(subject.body)['errors'] }

      context 'invalid enrichment with invalid content lack_presence fields' do
        let(:invalid_enrichment) { build(:provider_enrichment, :without_content) }
        let(:provider) {
          create(
            :provider,
            organisations: [organisation],
            enrichments: [invalid_enrichment]
          )
        }

        it { should have_http_status(:unprocessable_entity) }

        it 'has validation error details' do
          expect(json_data.count).to eq 9
          expect(json_data[0]["detail"]).to eq("Enter email address")
          expect(json_data[1]["detail"]).to eq("Enter website")
          expect(json_data[2]["detail"]).to eq("Enter telephone")
          expect(json_data[3]["detail"]).to eq("Enter building or street")
          expect(json_data[4]["detail"]).to eq("Enter town or city")
          expect(json_data[5]["detail"]).to eq("Enter county")
          expect(json_data[6]["detail"]).to eq("Enter a postcode in the format ‘SW10 1AA’")
          expect(json_data[7]["detail"]).to eq("Enter details about training with you")
          expect(json_data[8]["detail"]).to eq("Enter details about training with a disability")
        end

        it 'has validation error pointers' do
          expect(json_data[0]["source"]["pointer"]).to eq("/data/attributes/email")
          expect(json_data[1]["source"]["pointer"]).to eq("/data/attributes/website")
          expect(json_data[2]["source"]["pointer"]).to eq("/data/attributes/telephone")
          expect(json_data[3]["source"]["pointer"]).to eq("/data/attributes/address1")
          expect(json_data[4]["source"]["pointer"]).to eq("/data/attributes/address3")
          expect(json_data[5]["source"]["pointer"]).to eq("/data/attributes/address4")
          expect(json_data[6]["source"]["pointer"]).to eq("/data/attributes/postcode")
          expect(json_data[7]["source"]["pointer"]).to eq("/data/attributes/train_with_us")
          expect(json_data[8]["source"]["pointer"]).to eq("/data/attributes/train_with_disability")
        end
      end
    end
  end
end
