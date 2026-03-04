# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::Candidates authorization" do
  include DfESignInUserHelper

  let(:non_admin_user) { create(:user, admin: false) }
  let(:admin_user) { create(:user, :admin) }

  let(:target_candidate) { create(:candidate) }

  before do
    host! URI(Settings.base_url).host
  end

  describe "DELETE /support/candidates/:id/delete" do
    it "does not allow a non-admin to remove candidates" do
      login_user(non_admin_user)

      delete "/support/candidates/#{target_candidate.id}/delete"

      expect(response).to have_http_status(:forbidden)
      expect(target_candidate.reload).to be_present

      expect(Candidate.exists?(target_candidate.id)).to be(true)
    end

    it "allows an admin to remove candidates" do
      login_user(admin_user)

      delete "/support/candidates/#{target_candidate.id}/delete"

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(support_candidates_path)

      expect(Candidate.exists?(target_candidate.id)).to be(false)
    end
  end
end
