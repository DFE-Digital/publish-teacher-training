require 'rails_helper'

describe API::V2::ApplicationController, type: :controller do
  describe '#authenticate' do
    let(:encoded_token) do
      JWT.encode(
        payload,
        Settings.authentication.secret,
        Settings.authentication.algorithm
      )
    end
    let(:bearer_token) { "Bearer #{encoded_token}" }

    before do
      controller.response              = response
      request.headers['Authorization'] = bearer_token
    end

    subject { controller.authenticate }

    context 'with an email in the payload that matches a user' do
      let(:user)    { create(:user) }
      let(:payload) { { email: user.email } }

      it 'saves the user for use by the action' do
        controller.authenticate

        expect(assigns(:current_user)).to eq user
      end
    end

    context 'with an email in the payload that does not match a user' do
      let(:payload) { { email: Faker::Internet.email } }

      it { should eq "HTTP Token: Access denied.\n" }

      it 'requests authentication via the http header' do
        subject

        expect(response.headers['WWW-Authenticate'])
          .to eq('Token realm="Application"')
      end
    end
  end
end
