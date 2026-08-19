# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support manual provider rollover" do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let(:admin) { create(:user, :admin) }

  before do
    host! URI(Settings.base_url).host
    login_user(admin)
    create(:recruitment_cycle, :next) unless provider.recruitment_cycle.next
  end

  describe "GET /support/:recruitment_cycle_year/providers/:provider_id/manual_rollover" do
    it "counts the study sites, which are still only in the legacy site table" do
      create_list(:site, 3, :study_site, provider:)

      get manual_rollover_support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider)

      expect(response).to have_http_status(:ok)
      expect(study_sites_summary_row).to have_text("3")
    end

    def study_sites_summary_row
      Capybara.string(response.body).find(".govuk-summary-list__row", text: "Number of study sites")
    end
  end
end
