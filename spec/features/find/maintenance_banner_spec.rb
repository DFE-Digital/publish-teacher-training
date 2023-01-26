# frozen_string_literal: true

require "rails_helper"

feature "Maintenance banner" do
  context "given the maintenance_mode feature flag is active and i arrive at the site" do
    scenario "sends me to the maintenance page" do
      FeatureFlag.activate(:maintenance_banner)

      visit find_path

      expect(page).to have_content "This service will be unavailable on"
    end
  end

  context "given the maintenance_banner feature flag is deactive and i visit the homepage" do
    scenario "sends me to the homepage" do
      FeatureFlag.deactivate(:maintenance_banner)

      visit find_path

      expect(page).not_to have_content "This service will be unavailable on"
    end
  end
end
