# frozen_string_literal: true

require "rails_helper"

module Find
  module Candidates
    RSpec.describe NotesController, service: :find, type: :controller do
      let(:candidate) { create(:candidate) }
      let(:session_record) { create(:session, sessionable: candidate) }
      let(:saved_course) { create(:saved_course, candidate:) }

      before do
        FeatureFlag.activate(:candidate_accounts)
        request.host = URI(Settings.find_url).host
        cookies.signed[Settings.cookies.candidate_session.name] = session_record.session_key
      end

      describe "GET #edit" do
        it "renders successfully" do
          get :edit, params: { saved_course_id: saved_course.id }

          expect(response).to have_http_status(:ok)
        end
      end

      context "when not authenticated" do
        before do
          cookies.delete(Settings.cookies.candidate_session.name)
        end

        it "redirects unauthenticated users for edit" do
          get :edit, params: { saved_course_id: saved_course.id }

          expect(response).to redirect_to(find_root_path)
        end

        it "redirects unauthenticated users for update" do
          patch :update, params: { saved_course_id: saved_course.id, saved_course: { note: "Hi" } }

          expect(response).to redirect_to(find_root_path)
        end

        it "redirects unauthenticated users for destroy" do
          delete :destroy, params: { saved_course_id: saved_course.id }

          expect(response).to redirect_to(find_root_path)
        end

        it "redirects unauthenticated users for undo" do
          post :undo, params: { saved_course_id: saved_course.id, note: "Hi" }

          expect(response).to redirect_to(find_root_path)
        end
      end
    end
  end
end
