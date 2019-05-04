require 'rails_helper'

describe 'Access Request API V2', type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:requesting_user) { create(:user, organisations: [organisation]) }
  let(:requested_user) { create(:user) }
  let(:organisation) { create(:organisation) }
  let(:payload) { { email: admin_user.email } }
  let(:access_request) {
    create(:access_request,
           email_address: requested_user.email,
           requester_email: requesting_user.email,
           requester_id: requesting_user.id,
           organisation: organisation.name)
  }
  let(:token) do
    JWT.encode payload,
               Settings.authentication.secret,
               Settings.authentication.algorithm
  end
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  subject { response }

  describe 'GET #index' do
    let(:access_requests_index_route) do
      get "/api/v2/access_requests",
          headers: { 'HTTP_AUTHORIZATION' => credentials }
    end

    context 'when unauthenticated' do
      before do
        access_requests_index_route
      end

      let(:payload) { { email: 'foo@bar' } }

      it { should have_http_status(:unauthorized) }
    end

    context 'when unauthorized' do
      let(:unauthorised_user) { create(:user) }
      let(:payload) { { email: unauthorised_user.email } }
      let(:unauthorised_user_route) do
        get "/api/v2/access_requests",
            headers: { 'HTTP_AUTHORIZATION' => credentials }
      end


      it "should raise an error" do
        expect { unauthorised_user_route }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context 'when authorised' do
      let(:first_organisation) { create(:organisation, name: 'First Organisation') }
      let(:second_organisation) { create(:organisation, name: 'Second Organisation') }
      let(:first_user) {
        create(:user,
               first_name: 'First',
               last_name: 'User',
               email: 'first_user@test.com',
               organisations: [first_organisation])
      }
      let(:second_user) {
        create(:user,
               first_name: 'Second',
               last_name: 'User',
               email: "second_user@test.com",
               organisations: [second_organisation])
      }
      let!(:first_access_request) {
        create(:access_request,
               first_name: first_user.first_name,
               last_name: first_user.last_name,
               email_address: first_user.email,
               requester_email: second_user.email,
               requester_id: second_user.id,
               organisation: second_user.organisations.first.name,
               reason: 'Need additional support',
               request_date_utc: '2019-05-05 00:10:47 UTC',
               status: 'requested')
      }
      let!(:second_access_request) {
        create(:access_request,
               first_name: second_user.first_name,
               last_name: second_user.last_name,
               email_address: second_user.email,
               requester_email: first_user.email,
               requester_id: first_user.id,
               organisation: first_user.organisations.first.name,
               reason: 'Leaving current role',
               request_date_utc: '2019-05-05 00:10:48 UTC',
               status: 'requested')
      }
      let!(:third_access_request) { create(:access_request, status: 'approved') }
      before do
        access_requests_index_route
      end

      it 'JSON only includes requested access requests & displays the correct attributes' do
        json_response = JSON.parse response.body

        expect(json_response).to eq(
          [
            {
              "id" => first_access_request.id,
              "email_address" => first_access_request.recipient.email,
              "first_name" => first_access_request.recipient.first_name,
              "last_name" => first_access_request.recipient.last_name,
              "requester_email" => first_access_request.requester.email,
              "requester_id" => first_access_request.requester.id,
              "organisation" => first_access_request.organisation,
              "reason" => first_access_request.reason,
              "request_date_utc" => '2019-05-05T00:10:47.000Z',
              "status" => first_access_request.status
            },
            {
              "id" => second_access_request.id,
              "email_address" => second_access_request.recipient.email,
              "first_name" => second_access_request.recipient.first_name,
              "last_name" => second_access_request.recipient.last_name,
              "requester_email" => second_access_request.requester.email,
              "requester_id" => second_access_request.requester.id,
              "organisation" => second_access_request.organisation,
              "reason" => second_access_request.reason,
              "request_date_utc" => '2019-05-05T00:10:48.000Z',
              "status" => second_access_request.status
            }
          ]
       )
      end
    end
  end

  describe 'POST #approve' do
    let(:approve_route_request) do
      post "/api/v2/access_requests/#{access_request.id}/approve",
           headers: { 'HTTP_AUTHORIZATION' => credentials }
    end
    context 'when unauthenticated' do
      before do
        approve_route_request
      end

      let(:payload) { { email: 'foo@bar' } }

      it { should have_http_status(:unauthorized) }
    end

    context 'when unauthorized' do
      let(:unauthorised_user) { create(:user) }
      let(:payload) { { email: unauthorised_user.email } }

      it "should raise an error" do
        expect { approve_route_request }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context 'when authorised' do
      before do
        approve_route_request
      end

      it 'updates the requests status to completed' do
        expect(access_request.reload.status). to eq 'completed'
      end

      it 'has a successful response' do
        expect(response.body).to eq({ result: true }.to_json)
      end

      context 'when the user requested user already exists' do
        it 'gives a pre existing user access to the right organisations' do
          expect(requested_user.organisations).to eq requesting_user.organisations
        end
      end

      context 'when email address does not belong to a user' do
        let(:new_user_access_request) {
          create(:access_request,
                 first_name: 'test',
                 last_name: 'user',
                 email_address: 'test@user.com',
                 requester_email: requesting_user.email,
                 requester_id: requesting_user.id,
                 organisation: organisation.name)
        }
        before do
          post "/api/v2/access_requests/#{new_user_access_request.id}/approve",
               headers: { 'HTTP_AUTHORIZATION' => credentials }
        end

        it 'creates a new account for a new user and gives access to the right orgs' do
          new_user = User.find_by!(email: 'test@user.com')

          expect(new_user.organisations).to eq requesting_user.organisations
        end
      end
    end
  end
end
