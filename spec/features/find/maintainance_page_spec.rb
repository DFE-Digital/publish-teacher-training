# frozen_string_literal: true

require "rails_helper"

feature "Maintenance mode" do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  context "given the maintenance_mode feature flag is active and i arrive at the site" do
    scenario "sends me to the maintenance page" do
      allow(FeatureFlag).to receive(:active?)
      allow(FeatureFlag).to receive(:active?).with(:maintenance_mode).and_return(true)
      allow(FeatureFlag).to receive(:active?).with(:maintenance_banner).and_return(true)

      visit find_root_path

      expect(page).to have_current_path find_maintenance_path
      expect(page).to have_no_content "Service disruption today Thursday 9 October"
    end
  end

  context "given the maintenance_mode feature flag is deactive and i visit the maintenance_path" do
    scenario "sends me to the homepage" do
      FeatureFlag.deactivate(:maintenance_mode)

      visit find_maintenance_path

      expect(page).to have_current_path find_root_path
    end
  end

  context "given the maintenance_mode feature flag is active and I visit the feature flag page" do
    scenario "sends me to the feature flags page" do
      allow(FeatureFlag).to receive(:active?).with(:maintenance_mode).and_return(true)

      visit support_feature_flags_path

      expect(page).to have_current_path support_feature_flags_path
    end
  end
end
