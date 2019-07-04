require "rails_helper"

describe 'PATCH /api/v2/users/:id/accept_rollover_screen', type: :request do
  let(:user)    { create(:user, state: 'transitioned') }
  let(:payload) { { email: user.email } }

  let(:token) do
    JWT.encode payload,
               Settings.authentication.secret,
               Settings.authentication.algorithm
  end

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def perform_request
    patch(
      accept_rollover_screen_api_v2_user_path(user),
      headers: { 'HTTP_AUTHORIZATION' => credentials },
      params: {}
    )
  end

  context 'when unauthenticated' do
    let(:payload) { { email: 'foo@bar' } }

    before do
      perform_request
    end

    subject { response }

    it { should have_http_status(:unauthorized) }
  end

  context 'when unauthorized' do
    let(:unauthorised_user) { create(:user) }
    let(:payload) { { email: unauthorised_user.email } }

    it "raises an error" do
      expect { perform_request }.to raise_error Pundit::NotAuthorizedError
    end
  end

  context 'when authenticated and authorised' do
    it 'runs the accept_rollover_screen event on the user' do
      perform_request
      expect(user.reload).to be_rolled_over
    end

    it 'returns success' do
      perform_request
      expect(response).to have_http_status(:success)
    end

    context 'when user is already rolled over' do
      before do
        user.accept_rollover_screen!
      end

      it 'returns error' do
        expect { perform_request }.to raise_error AASM::InvalidTransition
      end
    end
  end
end
