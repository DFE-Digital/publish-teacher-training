# frozen_string_literal: true

require "rails_helper"

module Publish
  module Authentication
    describe SessionsController do
      include DfESignInUserHelper
      let(:user) { create(:user) }

      before do
        request.host = URI(Settings.publish_url).host
      end

      describe "#destroy" do
        context "existing database user" do
          before do
            session_key = SecureRandom.hex(32)
            user.sessions.create!(session_key:, id_token: "id_token")
            cookies.signed[Settings.cookies.user_session.name] = session_key
          end

          it "redirects to the DfE Sign-In logout URL" do
            post :destroy
            expect(response.location).to start_with("#{Settings.dfe_signin.issuer}/session/end")
            expect(response.location).to include("id_token_hint=id_token")
            expect(response).to be_redirect
          end

          it "destroys the user's session record" do
            expect { post :destroy }.to change { user.sessions.count }.from(1).to(0)
          end
        end

        context "non existing database user" do
          it "redirects to the root page" do
            post :destroy
            expect(response).to redirect_to(publish_root_path)
          end
        end
      end

      describe "#sign_out" do
        it "redirects to the auth/dfe/signout" do
          post :sign_out
          expect(response).to redirect_to("/auth/dfe/signout")
        end
      end

      describe "#callback" do
        let(:request_callback) do
          request.env["omniauth.auth"] = user_exists_in_dfe_sign_in(user:)
          get :callback
        end

        context "existing database user" do
          it "does not store user data in the cookie session" do
            request_callback
            expect(session["user"]).to be_nil
          end

          it "creates a database session record" do
            expect { request_callback }.to change { user.sessions.count }.by(1)
          end

          it "stores id_token in the database session" do
            request_callback
            expect(user.sessions.last.id_token).to eq("id_token")
          end

          it "redirects to the Publish root page" do
            request_callback
            expect(response).to redirect_to(publish_root_path)
          end
        end

        context "non existing database user" do
          let(:user) { build(:user) }

          it "does not create a database session" do
            expect { request_callback }.not_to change(Session, :count)
          end

          it "redirects to the sign in user not found page" do
            request_callback
            expect(response).to redirect_to(user_not_found_path)
          end
        end
      end
    end
  end
end
