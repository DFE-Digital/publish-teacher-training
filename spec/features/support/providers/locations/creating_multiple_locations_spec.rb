# frozen_string_literal: true

require 'rails_helper'

feature 'Multiple locations' do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
  end

  scenario 'submitting an empty form' do
    and_the_multiple_locations_feature_flag_is_active
    when_i_visit_a_provider_locations_page
    then_i_click_add_multiple_locations

    given_i_submit_an_empty_form
    # then_i_should_see_the_validation_error_message # this can be uncommented when the flow has been hooked up
  end

  scenario 'feature flag off' do
    when_i_visit_a_provider_locations_page
    then_i_should_not_see_the_add_multiple_locations_link
  end

  def when_i_visit_a_provider_locations_page
    visit support_recruitment_cycle_provider_locations_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  def provider
    @provider ||= create(:provider, sites: [build(:site)])
  end

  def and_the_multiple_locations_feature_flag_is_active
    allow(Settings.features).to receive(:add_multiple_locations).and_return(true)
  end

  def then_i_click_add_multiple_locations
    click_link 'Add multiple locations'
  end

  def then_i_should_not_see_the_add_multiple_locations_link
    expect(page).not_to have_link('Add multiple locations')
  end

  def given_i_submit_an_empty_form
    click_button 'Continue'
  end

  def then_i_should_see_the_validation_error_message
    expect(page).to have_text('Enter location details')
  end
end
