require 'rails_helper'

describe 'Sites API v2', type: :request do
  let(:user) { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:payload) { { email: user.email } }
  let(:token) { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:site1) { create :site, location_name: 'Main site 1' }
  let(:site2) { create :site, location_name: 'Main site 2' }
  let(:sites) { [site1, site2] }

  let!(:provider) {
    create(:provider,
           course_count: 0,
           site_count: 0,
           sites: sites,
           organisations: [organisation])
  }

  subject { response }

  describe 'GET show' do
    let(:show_path) do
      "/api/v2/providers/#{provider.provider_code}" +
        "/sites/#{site1.id}"
    end

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
  end

  describe 'GET index' do
    context 'when unauthenticated' do
      let(:payload) { { email: 'foo@bar' } }

      before do
        get "/api/v2/providers/#{provider.provider_code}/sites",
            headers: { 'HTTP_AUTHORIZATION' => credentials }
      end

      it { should have_http_status(:unauthorized) }
    end

    context 'when unauthorised' do
      let(:unauthorised_user) { create(:user) }
      let(:payload) { { email: unauthorised_user.email } }

      it "raises an error" do
        expect {
          get "/api/v2/providers/#{provider.provider_code}/sites",
            headers: { 'HTTP_AUTHORIZATION' => credentials }
        }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe 'JSON generated for sites' do
      before do
        get "/api/v2/providers/#{provider.provider_code}/sites",
            headers: { 'HTTP_AUTHORIZATION' => credentials }
      end

      it { should have_http_status(:success) }

      it 'has a data section with the correct attributes' do
        json_response = JSON.parse response.body
        expect(json_response).to eq(
          "data" => [{
            "id" => site1.id.to_s,
            "type" => "sites",
            "attributes" => {
              "code" => site1.code,
              "location_name" => site1.location_name,
              "address1" => site1.address1,
              "address2" => site1.address2,
              "address3" => site1.address3,
              "address4" => site1.address4,
              "postcode" => site1.postcode,
              "region_code" => site1.region_code
            },
          }, {
            "id" => site2.id.to_s,
            "type" => "sites",
            "attributes" => {
              "code" => site2.code,
              "location_name" => site2.location_name,
              "address1" => site2.address1,
              "address2" => site2.address2,
              "address3" => site2.address3,
              "address4" => site2.address4,
              "postcode" => site2.postcode,
              "region_code" => site2.region_code
            }
          }],
          "jsonapi" => {
            "version" => "1.0"
          }
        )
      end
    end

    it "raises a 'record not found' error when the provider doesn't exist" do
      expect {
        get("/api/v2/providers/non-existent-provider/sites",
         headers: { 'HTTP_AUTHORIZATION' => credentials })
      } .to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe 'PATCH update' do
    def perform_site_update
      patch(
        api_v2_provider_site_path(provider.provider_code, site1),
        headers: { 'HTTP_AUTHORIZATION' => credentials },
        params: params
      )
    end

    let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
    let(:params) do
      {
        _jsonapi: jsonapi_renderer.render(
          site1,
          class: {
            Site: API::V2::SerializableSite
          }
        )
      }
    end
    let(:site_params) { params.dig :_jsonapi, :data, :attributes }

    context 'when authenticted and authorised' do
      before do
        site_params.merge!(
          location_name: 'New location name'
        )
      end

      subject { perform_site_update }

      it 'updates the location name of the site' do
        expect { perform_site_update }.to change { site1.reload.location_name }
          .from('Main site 1')
          .to('New location name')
      end
    end
  end
end
