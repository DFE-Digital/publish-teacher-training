# frozen_string_literal: true

require 'rails_helper'

feature 'Maintenance mode' do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  context 'given the maintenance_mode feature flag is active and i arrive at the site' do
    scenario 'sends me to the maintenance page' do
      FeatureFlag.activate(:maintenance_mode)
      FeatureFlag.activate(:maintenance_banner)

      visit find_path

      expect(page).to have_current_path find_maintenance_path
      expect(page).not_to have_content 'This service will be unavailable on'
    end
  end

  context 'given the maintenance_mode feature flag is deactive and i visit the maintenance_path' do
    scenario 'sends me to the homepage' do
      FeatureFlag.deactivate(:maintenance_mode)

      visit find_maintenance_path

      expect(page).to have_current_path find_path
    end
  end

  context 'given the maintenance_mode feature flag is active and I visit the feature flag page' do
    scenario 'sends me to the feature flags page' do
      FeatureFlag.activate(:maintenance_mode)

      visit find_feature_flags_path

      expect(page).to have_current_path find_feature_flags_path
    end
  end
end
