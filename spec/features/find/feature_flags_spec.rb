# frozen_string_literal: true

require 'rails_helper'

feature 'Feature flags' do
  around do |example|
    Timecop.freeze(Time.zone.local(2021, 12, 1, 12)) do
      example.run
    end
  end

  before do
    given_there_is_a_feature_flag_set_up
  end

  scenario 'basic auth' do
    when_i_visit_the_features_page
    i_should_see_access_denied
  end

  scenario 'Manage features' do
    given_i_am_authenticated
    when_i_visit_the_features_page
    then_i_should_see_the_existing_feature_flags

    when_i_activate_the_feature
    then_the_feature_is_activated

    when_i_deactivate_the_feature
    then_the_feature_is_deactivated
  end

  def given_there_is_a_feature_flag_set_up
    allow(FeatureFlags).to receive(:all).and_return([[:test_feature, "It's a test feature", 'Jasmine Java']])

    FeatureFlag.deactivate('test_feature')
  end

  def when_i_visit_the_features_page
    find_feature_flag_page.load
  end

  def given_i_am_authenticated
    page.driver.browser.authorize 'admin', 'password'
  end

  def i_should_see_access_denied
    expect(page).to have_content('Access denied')
  end

  def then_i_should_see_the_existing_feature_flags
    within(feature_card) do
      expect(page).to have_content('Test feature')
      expect(page).to have_content(feature.owner)
      expect(page).to have_content(feature.description)
    end
  end

  def when_i_activate_the_feature
    within(feature_card) { click_link 'Confirm environment to make changes' }
    fill_in 'Type ‘test’ to confirm that you want to proceed', with: 'test'
    click_button 'Continue'

    within(feature_card) { click_button 'Activate' }
  end

  def then_the_feature_is_activated
    expect(FeatureFlag.active?('test_feature')).to be true
    expect(find_feature_flag_page).to have_content('Test feature')
    expect(find_feature_flag_page).to have_content('Active')
    expect(find_feature_flag_page).to have_content('12pm on 1 December 2021')
  end

  def when_i_deactivate_the_feature
    within(feature_card) { click_button 'Deactivate' }
  end

  def then_the_feature_is_deactivated
    expect(find_feature_flag_page).to have_content('Inactive')
    expect(FeatureFlag.active?('test_feature')).to be false
  end

  def feature_card
    find_feature_flag_page.find('.app-summary-card')
  end

  def feature
    @feature ||= FeatureFlag.features[:test_feature]
  end
end
