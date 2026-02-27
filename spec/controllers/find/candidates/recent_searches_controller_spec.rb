# frozen_string_literal: true

require "rails_helper"

module Find
  module Candidates
    RSpec.describe RecentSearchesController, service: :find, type: :controller do
      let(:candidate) { create(:candidate) }
      let(:session_record) { create(:session, sessionable: candidate) }

      before do
        FeatureFlag.activate(:candidate_accounts)
        request.host = URI(Settings.find_url).host
        cookies.signed[Settings.cookies.candidate_session.name] = session_record.session_key
      end

      describe "GET #index" do
        it "renders successfully with active searches" do
          create(:recent_search, find_candidate: candidate, subjects: %w[C1])
          discarded = create(:recent_search, find_candidate: candidate, subjects: %w[F1])
          discarded.discard

          get :index

          expect(response).to have_http_status(:ok)
        end

        it "discards stale searches" do
          stale = create(:recent_search, find_candidate: candidate, updated_at: 31.days.ago)

          get :index

          expect(stale.reload).to be_discarded
        end
      end

      describe "DELETE #clear_all" do
        it "discards all active searches" do
          search1 = create(:recent_search, find_candidate: candidate, subjects: %w[C1])
          search2 = create(:recent_search, find_candidate: candidate, subjects: %w[F1])

          delete :clear_all

          expect(search1.reload).to be_discarded
          expect(search2.reload).to be_discarded
        end

        it "does not affect another candidate's searches" do
          other_candidate = create(:candidate)
          other_search = create(:recent_search, find_candidate: other_candidate)

          create(:recent_search, find_candidate: candidate)
          delete :clear_all

          expect(other_search.reload).not_to be_discarded
        end

        it "redirects to the index with a success flash" do
          create(:recent_search, find_candidate: candidate)

          delete :clear_all

          expect(response).to redirect_to(find_candidate_recent_searches_path)
          expect(flash[:success_with_body]["title"]).to eq("Recent searches cleared")
          expect(flash[:success_with_body]["body"]).to include("All your recent searches have been deleted.")
        end
      end

      describe "POST #undo" do
        it "undiscards searches by the given IDs" do
          search1 = create(:recent_search, find_candidate: candidate, subjects: %w[C1])
          search2 = create(:recent_search, find_candidate: candidate, subjects: %w[F1])
          search1.discard
          search2.discard

          post :undo, params: { ids: [search1.id, search2.id] }

          expect(search1.reload).not_to be_discarded
          expect(search2.reload).not_to be_discarded
        end

        it "does not undiscard searches belonging to another candidate" do
          other_candidate = create(:candidate)
          other_search = create(:recent_search, find_candidate: other_candidate)
          other_search.discard

          post :undo, params: { ids: [other_search.id] }

          expect(other_search.reload).to be_discarded
        end

        it "redirects to the index" do
          post :undo, params: { ids: [] }

          expect(response).to redirect_to(find_candidate_recent_searches_path)
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

        it "redirects unauthenticated users for clear_all" do
          delete :clear_all
          expect(response).to redirect_to(find_root_path)
        end

        it "redirects unauthenticated users for undo" do
          post :undo, params: { ids: [] }
          expect(response).to redirect_to(find_root_path)
        end
      end
    end
  end
end
