# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::Candidates::EmailAlerts authorization" do
  include DfESignInUserHelper

  let(:non_admin_user) { create(:user, admin: false) }
  let(:admin_user) { create(:user, :admin) }

  let(:target_candidate) { create(:candidate) }
  let(:email_alert) { create(:email_alert, candidate: target_candidate) }

  before do
    host! URI(Settings.base_url).host
  end

  describe "GET /support/candidates/:candidate_id/email_alerts" do
    it "does not allow a non-admin to view email alerts" do
      login_user(non_admin_user)

      get "/support/candidates/#{target_candidate.id}/email_alerts"

      expect(response).to have_http_status(:forbidden)
    end

    it "allows an admin to view email alerts" do
      login_user(admin_user)

      get "/support/candidates/#{target_candidate.id}/email_alerts"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /support/candidates/:candidate_id/email_alerts/:id/confirm_unsubscribe" do
    it "does not allow a non-admin to unsubscribe" do
      login_user(non_admin_user)

      delete "/support/candidates/#{target_candidate.id}/email_alerts/#{email_alert.id}/confirm_unsubscribe"

      expect(response).to have_http_status(:forbidden)
      expect(email_alert.reload.unsubscribed_at).to be_nil
    end

    it "allows an admin to unsubscribe" do
      login_user(admin_user)

      delete "/support/candidates/#{target_candidate.id}/email_alerts/#{email_alert.id}/confirm_unsubscribe"

      expect(response).to have_http_status(:redirect)
      expect(email_alert.reload.unsubscribed_at).to be_present
    end
  end
end
