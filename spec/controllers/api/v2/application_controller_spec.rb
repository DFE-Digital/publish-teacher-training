require 'rails_helper'

describe API::V2::ApplicationController, type: :controller do
  describe '#authenticate' do
    let(:user) { create(:user) }
    let(:payload) { { email: user.email } }
    let(:encoded_token) do
      JWT.encode payload,
                 Settings.authentication.secret,
                 Settings.authentication.algorithm
    end
    let(:bearer_token) { "Bearer #{encoded_token}" }

    before do
      controller.response = response
      request.headers['Authorization'] = bearer_token
    end

    subject { controller.authenticate }

    it 'saves the user for use by the action' do
      controller.authenticate

      expect(assigns(:current_user)).to eq user
    end

    context 'algorithm is not plain-text' do
      it { should be true }

      it 'saves the user for use by the action' do
        controller.authenticate

        expect(assigns(:current_user)).to eq user
      end

      context 'user is not valid' do
        let(:payload) { { email: 'foobar' } }

        it { should eq "HTTP Token: Access denied.\n" }

        it 'requests authentication via the http header' do
          controller.authenticate

          expect(response.headers['WWW-Authenticate'])
            .to eq 'Token realm="Application"'
        end
      end

      describe 'errors' do
        context 'empty payload' do
          let(:payload) {}

          it 'raise error' do
            expect { controller.authenticate }.to raise_error NoMethodError
          end
        end

        context 'JWT mismatch' do
          context 'secret' do
            let(:encoded_token) do
              JWT.encode payload,
                         'mismatch secret',
                         Settings.authentication.algorithm
            end

            it 'raise error' do
              expect { controller.authenticate }.to raise_error JWT::VerificationError
            end
          end

          context 'encoding' do
            let(:encoded_token) do
              JWT.encode payload,
                         Settings.authentication.secret,
                         'HS384'
            end

            it 'raise error' do
              expect { controller.authenticate }.to raise_error JWT::IncorrectAlgorithm
            end
          end
        end
      end
    end

    context 'algorithm is set to plain-text' do
      let(:bearer_token) { "Bearer #{user.email}" }

      before do
        allow(Settings).to receive_message_chain(:authentication, :algorithm)
                             .and_return('plain-text')
      end

      it { should be true }

      context 'user does not exist' do
        let(:bearer_token) { "Bearer nobody@nowhere" }

        it { should eq "HTTP Token: Access denied.\n" }
      end
    end
  end
end
