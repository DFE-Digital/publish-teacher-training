# frozen_string_literal: true

require "rails_helper"

module Find
  module Candidates
    RSpec.describe EmailAlertsController, service: :find, type: :controller do
      let(:candidate) { create(:candidate) }
      let(:session_record) { create(:session, sessionable: candidate) }

      before do
        FeatureFlag.activate(:candidate_accounts)
        FeatureFlag.activate(:email_alerts)
        request.host = URI(Settings.find_url).host
        cookies.signed[Settings.cookies.candidate_session.name] = session_record.session_key
      end

      describe "GET #index" do
        it "renders successfully with active alerts" do
          create(:email_alert, candidate:, subjects: %w[C1])
          unsubscribed = create(:email_alert, candidate:, subjects: %w[F1])
          unsubscribed.unsubscribe!

          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      describe "GET #new" do
        it "renders the new alert form" do
          get :new, params: { subjects: %w[C1], level: "secondary" }

          expect(response).to have_http_status(:ok)
        end
      end

      describe "POST #create" do
        it "creates an email alert and redirects with success flash" do
          post :create, params: { subjects: %w[C1], level: "secondary" }

          expect(candidate.email_alerts.count).to eq(1)
          expect(response).to redirect_to(find_results_path(subjects: %w[C1], level: "secondary"))
          expect(flash[:success_with_body]["title"]).to eq("Email alert created")
        end

        it "redirects to recent searches when return_to is set" do
          post :create, params: { subjects: %w[C1], return_to: "recent_searches" }

          expect(response).to redirect_to(find_candidate_recent_searches_path)
        end
      end

      describe "GET #confirm_unsubscribe" do
        it "renders the confirmation page" do
          alert = create(:email_alert, candidate:)
          token = alert.signed_id(purpose: :unsubscribe, expires_in: 30.days)

          get :confirm_unsubscribe, params: { token: }

          expect(response).to have_http_status(:ok)
        end
      end

      describe "DELETE #unsubscribe" do
        it "unsubscribes the alert and redirects with success flash" do
          alert = create(:email_alert, candidate:)
          token = alert.signed_id(purpose: :unsubscribe, expires_in: 30.days)

          delete :unsubscribe, params: { token: }

          expect(alert.reload.unsubscribed_at).to be_present
          expect(response).to redirect_to(find_candidate_email_alerts_path)
          expect(flash[:success_with_body]["title"]).to eq("We've unsubscribed you from this email alert")
        end

        it "does not allow unsubscribing another candidate's alert" do
          other = create(:candidate)
          alert = create(:email_alert, candidate: other)
          token = alert.signed_id(purpose: :unsubscribe, expires_in: 30.days)

          delete :unsubscribe, params: { token: }

          expect(alert.reload.unsubscribed_at).to be_nil
        end
      end

      describe "GET #unsubscribe_from_email" do
        it "renders the confirmation page for a valid token" do
          alert = create(:email_alert, candidate:)
          token = alert.signed_id(purpose: :unsubscribe, expires_in: 30.days)

          # Remove auth cookie — this should work without authentication
          cookies.delete(Settings.cookies.candidate_session.name)

          get :unsubscribe_from_email, params: { token: }

          expect(response).to have_http_status(:ok)
        end

        it "redirects for an invalid token" do
          cookies.delete(Settings.cookies.candidate_session.name)

          get :unsubscribe_from_email, params: { token: "invalid" }

          expect(response).to redirect_to(find_root_path)
        end
      end

      describe "DELETE #confirm_unsubscribe_from_email" do
        it "unsubscribes the alert via token and redirects" do
          alert = create(:email_alert, candidate:)
          token = alert.signed_id(purpose: :unsubscribe, expires_in: 30.days)

          cookies.delete(Settings.cookies.candidate_session.name)

          delete :confirm_unsubscribe_from_email, params: { token: }

          expect(alert.reload.unsubscribed_at).to be_present
          expect(response).to redirect_to(find_root_path)
          expect(flash[:success_with_body]["title"]).to eq("We've unsubscribed you from this email alert")
        end
      end

      context "when not authenticated" do
        before do
          cookies.delete(Settings.cookies.candidate_session.name)
        end

        it "redirects unauthenticated users for index" do
          get :index
          expect(response).to redirect_to(find_root_path)
        end

        it "redirects unauthenticated users for new" do
          get :new
          expect(response).to redirect_to(find_root_path)
        end

        it "redirects unauthenticated users for create" do
          post :create
          expect(response).to redirect_to(find_root_path)
        end

        it "redirects unauthenticated users for confirm_unsubscribe" do
          get :confirm_unsubscribe, params: { token: "anytoken" }
          expect(response).to redirect_to(find_root_path)
        end

        it "redirects unauthenticated users for unsubscribe" do
          delete :unsubscribe, params: { token: "anytoken" }
          expect(response).to redirect_to(find_root_path)
        end
      end
    end
  end
end
