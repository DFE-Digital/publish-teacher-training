# frozen_string_literal: true

require "rails_helper"

describe "Sidekiq authorization" do
  include DfESignInUserHelper

  before { host! URI(Settings.base_url).host }

  describe "GET /sidekiq" do
    context "when not authenticated" do
      it "redirects to sign in" do
        get "/sidekiq"

        expect(response).to redirect_to("/sign-in")
      end
    end

    context "when authenticated as a non-admin user" do
      let(:user) { create(:user, :with_provider) }

      before { login_user(user) }

      it "redirects to sign in" do
        get "/sidekiq"

        expect(response).to redirect_to("/sign-in")
      end
    end

    context "when authenticated as an admin with an active session" do
      let(:user) { create(:user, :admin) }

      before { login_user(user) }

      it "returns success" do
        get "/sidekiq"

        expect(response).to have_http_status(:ok)
      end
    end

    context "when authenticated as an admin with a timed out session" do
      let(:user) { create(:user, :admin) }

      before do
        login_user(user)
        user.sessions.last.update_columns(updated_at: 1.minute.until(Session::USER_TIMEOUT.ago))
      end

      it "redirects to sign in" do
        get "/sidekiq"

        expect(response).to redirect_to("/sign-in")
      end
    end
  end
end
