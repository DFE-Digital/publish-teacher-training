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
