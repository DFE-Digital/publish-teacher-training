require 'rails_helper'

shared_examples 'Unauthenticated, unauthorised, or not accepted T&Cs' do
  context 'when unauthenticated' do
    let(:payload) { { email: 'foo@bar' } }

    it { should have_http_status(:unauthorized) }
  end

  context 'when user has not accepted terms' do
    let(:user)         { create(:user, :inactive) }
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
