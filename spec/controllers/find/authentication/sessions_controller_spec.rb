# frozen_string_literal: true

require "rails_helper"

module Find
  module Authentication
    describe SessionsController do
      let(:candidate) { create(:candidate) }

      before do
        FeatureFlag.activate(:candidate_accounts)
        request.host = URI(Settings.find_url).host
      end

      describe "#destroy" do
        before do
          CandidateAuthHelper.mock_auth(email_address: candidate.email_address)
        end

        context "existing database candidate" do
          before do
            session_key = SecureRandom.hex(32)
            candidate.sessions.create!(session_key:, id_token: "id_token")
            cookies.signed[Settings.cookies.candidate_session.name] = session_key
          end

          it "redirects to the find root url" do
            post :destroy
            expect(response).to redirect_to(find_root_path)
          end

          it "destroys the candidate's session record" do
            expect { post :destroy }.to change { candidate.sessions.count }.from(1).to(0)
          end

          it "sets a sign out flash message" do
            post :destroy
            expect(flash[:success]).to eq(I18n.t("find.authentication.sessions.sign_out"))
          end

          context "when One Login is enabled" do
            before do
              allow(Settings.one_login).to receive(:enabled).and_return(true)
            end

            it "redirects to the One Login end-session endpoint" do
              post :destroy
              expect(response).to be_redirect
              expect(response.location).to start_with(Settings.one_login.logout_url)
            end

            it "still destroys the candidate's session record" do
              expect { post :destroy }.to change { candidate.sessions.count }.from(1).to(0)
            end
          end
        end

        context "when there is no active session" do
          it "redirects to the find root url" do
            post :destroy
            expect(response).to redirect_to(find_root_path)
          end

          it "does not raise" do
            expect { post :destroy }.not_to raise_error
          end
        end
      end

      describe "#callback" do
        before do
          CandidateAuthHelper.mock_auth(email_address: candidate.email_address)
        end

        let(:request_callback) do
          request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:"find-developer"]
          get :callback, params: { provider: "find-developer" }
        end

        it "protects against redirecting to other hosts" do
          request.env["omniauth.origin"] = "https://fake.com"
          expect { request_callback }.to(raise_error(ActionController::Redirecting::OpenRedirectError))
        end

        context "existing database candidate with authentication" do
          let(:candidate) { create(:find_developer_candidate) }

          it "does not store candidate data in the cookie session" do
            request_callback
            expect(session["candidate"]).to be_nil
          end

          it "creates a database session record" do
            expect { request_callback }.to change { candidate.sessions.reload.count }.by(1)
          end

          it "does not create a new candidate" do
            candidate
            expect { request_callback }.not_to change(Candidate, :count)
          end

          it "stores subject_key in the candidate's authentication" do
            request_callback
            expect(candidate.authentications.last.subject_key).to eq("sign_in_user_id")
          end

          it "redirects to the find root page" do
            request_callback
            expect(response).to redirect_to(find_root_path)
          end

          it "sets a sign in flash message" do
            request_callback
            expect(flash[:success]).to eq(I18n.t("find.authentication.sessions.sign_in"))
          end

          it "redirects to a same-host omniauth origin when present" do
            request.env["omniauth.origin"] = "#{find_root_url}results"
            request_callback
            expect(response).to redirect_to("#{find_root_url}results")
          end

          it "falls back to the return_to_after_authenticating path when no origin is set" do
            request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:"find-developer"]
            get :callback,
                params: { provider: "find-developer" },
                session: { "return_to_after_authenticating" => "/results" }
            expect(response).to redirect_to("/results")
          end
        end

        context "candidate without an existing authentication" do
          let(:candidate) { build(:candidate) }

          it "signs the candidate up by creating a candidate record" do
            expect { request_callback }.to change(Candidate, :count).by(1)
          end

          it "creates a database session" do
            expect { request_callback }.to change(Session, :count).by(1)
          end

          it "redirects to the find root page" do
            request_callback
            expect(response).to redirect_to(find_root_path)
          end

          it "stores subject_key in the new candidate's authentication" do
            request_callback
            new_candidate = Candidate.find_by(email_address: candidate.email_address)
            expect(new_candidate.authentications.last.subject_key).to eq("sign_in_user_id")
          end
        end
      end
    end
  end
end
