require "rails_helper"

describe 'PATCH /api/v2/users/:id/accept_terms', type: :request do
  let(:user)    { create(:user, state: 'new', accept_terms_date_utc: nil) }
  let(:payload) { { email: user.email } }

  let(:token) do
    JWT.encode payload,
               Settings.authentication.secret,
               Settings.authentication.algorithm
  end

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  context 'when unauthenticated' do
    let(:payload) { { email: 'foo@bar' } }

    before do
      perform_request user
    end

    subject { response }

    it { should have_http_status(:unauthorized) }
  end

  context 'when unauthorized' do
    let(:unauthorised_user) { create(:user) }
    let(:payload) { { email: unauthorised_user.email } }

    it "raises an error" do
      expect { perform_request(user) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  context 'when authenticated and authorised' do
    before do
      Timecop.freeze
    end

    after do
      Timecop.return
    end

    it 'returns success' do
      perform_request user
      expect(response).to have_http_status(:success)
    end

    it 'sets the accept_terms_date_utc on the user object' do
      perform_request user
      expect(user.reload.accept_terms_date_utc).to be_within(1.second).of Time.now.utc
    end

    describe 'for wrong user' do
      let(:other_user) { create(:user, state: 'new', accept_terms_date_utc: nil) }

      it "raises an error" do
        expect { perform_request(other_user) }.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  def perform_request(target_user)
    patch(
      accept_terms_api_v2_user_path(target_user),
      headers: { 'HTTP_AUTHORIZATION' => credentials },
      params: {}
    )
  end
end
