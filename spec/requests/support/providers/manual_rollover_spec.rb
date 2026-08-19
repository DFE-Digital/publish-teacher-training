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
    # Schools are counted from Provider::School, so the summary is right for a
    # provider whose schools were never mirrored into the legacy site table.
    it "counts the schools the provider will roll over" do
      create_list(:provider_school, 2, provider:)

      get manual_rollover_support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider)

      expect(response).to have_http_status(:ok)
      expect(schools_summary_row).to have_text("2")
    end

    it "counts the study sites, which are still only in the legacy site table" do
      create_list(:site, 3, :study_site, provider:)

      get manual_rollover_support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider)

      expect(response).to have_http_status(:ok)
      expect(study_sites_summary_row).to have_text("3")
    end

    def schools_summary_row
      Capybara.string(response.body).find(".govuk-summary-list__row", text: "Number of schools")
    end

    def study_sites_summary_row
      Capybara.string(response.body).find(".govuk-summary-list__row", text: "Number of study sites")
    end
  end
end
