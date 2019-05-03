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

    context "when the provider doesn't exist" do
      before do
        get("/api/v2/providers/non-existent-provider/sites",
            headers: { 'HTTP_AUTHORIZATION' => credentials })
      end

      it { should have_http_status(:not_found) }
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

    before do
      allow(ManageCoursesAPIService::Request).to(
        receive(:sync_courses_with_search_and_compare).and_return(true)
      )
    end

    context 'when unauthenticated' do
      let(:payload) { { email: 'foo@bar' } }

      subject { response }

      before do
        perform_site_update
      end

      it { should have_http_status(:unauthorized) }
    end

    context 'when unauthorised' do
      let(:unauthorised_user) { create(:user) }
      let(:payload) { { email: unauthorised_user.email } }

      it 'raises an error' do
        expect { perform_site_update }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context 'when authenticated and authorised' do
      let(:code)          { 'A3' }
      let(:location_name) { 'New location name' }
      let(:address1)      { 'New street 1' }
      let(:address2)      { 'New street 2' }
      let(:address3)      { 'New city' }
      let(:address4)      { 'New state' }
      let(:postcode)      { 'SW1A 1AA' }
      let(:region_code)   { 'west_midlands' }

      subject { perform_site_update }

      before do
        site_params.merge!(
          code: code,
          location_name: location_name,
          address1: address1,
          address2: address2,
          address3: address3,
          address4: address4,
          postcode: postcode,
          region_code: region_code
        )
      end

      it 'updates the location name of the site' do
        expect { subject }.to change { site1.reload.location_name }
          .from(site1.location_name)
          .to(location_name)
      end

      it 'does not update the code of the site' do
        expect { subject }.not_to(change { site1.reload.code })
      end

      it 'updates the address1 of the site' do
        expect { subject }.to change { site1.reload.address1 }
          .from(site1.address1)
          .to(address1)
      end

      it 'updates the address2 of the site' do
        expect { subject }.to change { site1.reload.address2 }
          .from(site1.address2)
          .to(address2)
      end

      it 'updates the address3 of the site' do
        expect { subject }.to change { site1.reload.address3 }
          .from(site1.address3)
          .to(address3)
      end

      it 'updates the address4 of the site' do
        expect { subject }.to change { site1.reload.address4 }
          .from(site1.address4)
          .to(address4)
      end

      it 'updates the post code of the site' do
        expect { subject }.to change { site1.reload.postcode }
          .from(site1.postcode)
          .to(postcode)
      end

      it 'updates the region code of the site' do
        expect { subject }.to change { site1.reload.region_code }
          .from(site1.region_code)
          .to(region_code)
      end

      context 'response output' do
        let(:json_data) { JSON.parse(response.body)['data'] }

        before do
          perform_site_update
        end

        subject { response }

        it { should have_http_status(:success) }

        it 'publishes courses on manage-courses-api' do
          expect(ManageCoursesAPIService::Request).to(
            have_received(:sync_courses_with_search_and_compare)
            .with(user.email, provider.provider_code)
          )
        end

        it 'returns a JSON repsentation of the updated site' do
          expect(json_data).to have_id(site1.id.to_s)
          expect(json_data).to have_type('sites')
          expect(json_data).to have_attributes(
            :code,
            :location_name,
            :address1,
            :address2,
            :address3,
            :address4,
            :postcode,
            :region_code
          )
        end

        context 'with validation errors' do
          let(:json_data) { JSON.parse(response.body)['errors'] }

          context 'with missing attributes' do
            let(:location_name) { '' }
            let(:address1)      { '' }
            let(:address3)      { '' }
            let(:postcode)      { '' }
            let(:region_code)   { '' }

            it { should have_http_status(:unprocessable_entity) }

            it 'has the right amount of errors' do
              expect(json_data.count).to eq 5
            end

            it 'checks the location_name is present' do
              expect(response.body).to include('Invalid location_name')
              expect(response.body).to include("Location name can't be blank")
            end

            it 'checks the address1 is present' do
              expect(response.body).to include('Invalid address1')
              expect(response.body).to include("Address1 can't be blank")
            end

            it 'checks the address3 is present' do
              expect(response.body).to include('Invalid address3')
              expect(response.body).to include("Address3 can't be blank")
            end

            it 'checks the postcode is present' do
              expect(response.body).to include('Invalid postcode')
              expect(response.body).to include("Postcode can't be blank")
            end

            it 'checks the postcode is present' do
              expect(response.body).to include('Invalid postcode')
              expect(response.body).to include('Postcode not recognised as a UK postcode')
            end

            xit 'checks the region_code is present' do
            end
          end

          context 'with an already existing location_name' do
            context 'within the same provider' do
              let(:location_name) { site2.location_name }

              it 'checks the location_name is unique' do
                expect(json_data.count).to eq 1
                expect(response.body).to include('Invalid location_name')
                expect(response.body).to include('Location name has already been taken')
              end
            end

            context 'within another provider' do
              let!(:provider2) { create :provider, sites: [site3] }
              let!(:site3) { create :site, location_name: site1.location_name }
              let(:location_name) { site3.location_name }

              it { should have_http_status(:success) }

              it 'does not have a validation error' do
                expect(response.body).not_to include('errors')
              end
            end
          end
        end
      end
    end
  end
end
